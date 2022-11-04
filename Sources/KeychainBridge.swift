//
// KeychainBridge.swift
//
// Created by Andriy Slyusar on 2019-08-23.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import Security

open class KeychainBridge<T> {
    /// TBD
    open func encode(_ value: T) throws -> Data { fatalError() }

    /// TBD
    open func decode(_ data: Data) throws -> T? { fatalError() }

    public init() {}
}

extension KeychainBridge {
    func set<S: KeychainSerializable>(_ value: T, forKey keychainKey: KeychainKey<S>, in keychain: Keychain) throws {
        let attributesToSearch: [Attribute] = keychain.searchRequestAttributes
            + [KeychainAttribute.account(keychainKey.key)]

        let status = keychainItemFetch(attributesToSearch)
        switch status {
                // Keychain already contains key -> update existing item
            case errSecSuccess:
                let attributesToUpdate = keychainKey.updateRequestAttributes(itemClass: keychain.itemClass)
                + keychain.updateRequestAttributes
                + [KeychainAttribute.valueData(try encode(value))]

                let status = keychainItemUpdate(
                    attributesToSearch: attributesToSearch,
                    attributesToUpdate: attributesToUpdate
                )
                if status != errSecSuccess {
                    throw KeychainError(status: status)
                }

                // Keychain doesn't contain key -> add new item
            case errSecItemNotFound:
                let attributesToAdd = keychain.searchRequestAttributes
                + keychain.updateRequestAttributes
                + keychainKey.updateRequestAttributes(itemClass: keychain.itemClass)
                + [KeychainAttribute.account(keychainKey.key), KeychainAttribute.valueData(try encode(value))]

                let status = keychainItemAdd(attributesToAdd)
                if status != errSecSuccess {
                    throw KeychainError(status: status)
                }

                // This error can happen when your app is launched in the background while the device is locked
                // (for example, in response to an actionable push notification or a Core Location geofence event),
                // the application may crash as a result of accessing a locked keychain entry.
                //
                // TODO: Maybe introduce `force` property to allow remove and save key with different permissions
            case errSecInteractionNotAllowed:
                throw KeychainError(status: status)

            default:
                throw KeychainError(status: status)
        }
    }

    func get(key: String, from keychain: Keychain) throws -> T? {
        let attributesToSearch: [Attribute] = keychain.searchRequestAttributes
            + [KeychainAttribute.account(key)]
            + [SearchResultAttribute.matchLimit(.one)]
            + [ReturnResultAttribute.returnData(true)]

        var result: AnyObject?
        let status = SecItemCopyMatching(attributesToSearch.compose(), &result)
        switch status {
            case errSecSuccess:
                guard let data = result as? Data else {
                    throw KeychainError.unexpectedError
                }
                return try decode(data)
            case errSecItemNotFound:
                return nil
            default:
                throw KeychainError(status: status)
        }
    }

    func attributes(key: String, from keychain: Keychain) throws -> [KeychainAttribute] {
        let attributesToSearch: [Attribute] = keychain.searchRequestAttributes
            + [KeychainAttribute.account(key)]
            + [SearchResultAttribute.matchLimit(.one)]
            + [
                ReturnResultAttribute.returnAttributes(true),
                ReturnResultAttribute.returnRef(true),
                ReturnResultAttribute.returnPersistentRef(true),
            ]

        var result: AnyObject?
        let status = SecItemCopyMatching(attributesToSearch.compose(), &result)
        switch status {
            case errSecSuccess:
                guard let data = result as? [String: Any] else {
                    throw KeychainError.unexpectedError
                }

                let attrs: [KeychainAttribute] = data.compactMap { KeychainAttribute(key: $0, value: $1) }

                return attrs

            default:
                throw KeychainError(status: status)
        }
    }

    func remove(key: String, from keychain: Keychain) throws {
        let attributesToSearch: [Attribute] = keychain.searchRequestAttributes
            + [KeychainAttribute.account(key)]

        let status = keychainItemDelete(attributesToSearch)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError(status: status)
        }
    }
}

class KeychainBridgeInt: KeychainBridge<Int> {
    override open func encode(_ value: Int) throws -> Data {
        Data(from: value)
    }

    override open func decode(_ data: Data) throws -> Int? {
        data.convert(type: Int.self)
    }
}

class KeychainBridgeString: KeychainBridge<String> {
    override open func encode(_ value: String) throws -> Data {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.conversionError
        }
        return data
    }

    override open func decode(_ data: Data) throws -> String? {
        String(data: data, encoding: .utf8)
    }
}

class KeychainBridgeDouble: KeychainBridge<Double> {
    override open func encode(_ value: Double) throws -> Data {
        Data(from: value)
    }

    override open func decode(_ data: Data) throws -> Double? {
        data.convert(type: Double.self)
    }
}

class KeychainBridgeFloat: KeychainBridge<Float> {
    override open func encode(_ value: Float) throws -> Data {
        Data(from: value)
    }

    override open func decode(_ data: Data) throws -> Float? {
        data.convert(type: Float.self)
    }
}

class KeychainBridgeBool: KeychainBridge<Bool> {
    override open func encode(_ value: Bool) throws -> Data {
        let bytes: [UInt8] = value ? [1] : [0]
        return Data(bytes)
    }

    override open func decode(_ data: Data) throws -> Bool? {
        guard let firstBit = data.first else {
            return nil
        }
        return firstBit == 1
    }
}

class KeychainBridgeData: KeychainBridge<Data> {
    override open func encode(_ value: Data) throws -> Data {
        value
    }

    override open func decode(_ data: Data) throws -> Data? {
        data
    }
}

class KeychainBridgeCodable<T: Codable>: KeychainBridge<T> {
    override open func encode(_ value: T) throws -> Data {
        try JSONEncoder().encode(value)
    }

    override open func decode(_ data: Data) throws -> T? {
        try JSONDecoder().decode(T.self, from: data)
    }
}

class KeychainBridgeArchivable<T: NSCoding>: KeychainBridge<T> {
    override open func encode(_ value: T) throws -> Data {
        // TODO: iOS 13 deprecated +archivedDataWithRootObject:requiringSecureCoding:error:
        NSKeyedArchiver.archivedData(withRootObject: value)
    }

    override open func decode(_ data: Data) throws -> T? {
        // TODO: iOS 13 deprecated +unarchivedObjectOfClass:fromData:error:
        guard let value = NSKeyedUnarchiver.unarchiveObject(with: data) as? T else {
            throw KeychainError.invalidDataCast
        }
        return value
    }
}

func keychainItemDelete(_ attributes: [Attribute]) -> OSStatus {
    return SecItemDelete(attributes.compose())
}

func keychainItemAdd(_ attributes: [Attribute]) -> OSStatus {
    return SecItemAdd(attributes.compose(), nil)
}

/// Modifies items that match a search query.
/// Keychain SecItemUpdate do not allow search query parameters and account to pass as `attributesToUpdate`
/// - Parameters:
///   - query: Attributes collection that describes the search for the keychain items you want to update.
///   - attributes: Attributes collection containing the attributes whose values should be changed, along with the new values.
/// - Returns: A result code
func keychainItemUpdate(attributesToSearch: [Attribute], attributesToUpdate: [Attribute]) -> OSStatus {
    return SecItemUpdate(attributesToSearch.compose(), attributesToUpdate.compose())
}

func keychainItemFetch(_ attributes: [Attribute]) -> OSStatus {
    return SecItemCopyMatching(attributes.compose(), nil)
}

/// https://stackoverflow.com/a/38024025/2845836
extension Data {
    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    // TODO: Throw KeychainError.conversionError instead of nil
    func convert<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
}

extension [Attribute] {
    func compose() -> CFDictionary {
        return self.map(\.element).reduce(into: [CFString: Any]()) { $0[$1.key] = $1.value } as CFDictionary
    }
}

extension Keychain {
    /// Build keychain search request attributes
    var searchRequestAttributes: [Attribute] {
        var attributes = [Attribute]()
        attributes.append(KeychainAttribute.class(itemClass))
        attributes.append(SynchronizableAnyAttribute())

        switch itemClass {
            case .genericPassword:
                guard let service = service else {
                    // TODO: Replace fatal error with throw error instead
                    fatalError("`Service` property is mandatory for saving generic password keychaion item")
                }
                attributes.append(KeychainAttribute.service(service))

                // TODO: Access group is not supported on any simulators.
                if let accessGroup {
                    attributes.append(KeychainAttribute.accessGroup(accessGroup))
                }

            case .internetPassword:
                guard
                    let host = server?.host,
                    let protocolType = protocolType,
                    let authenticationType = authenticationType
                else {
                    // TODO: Replace fatal error with throw error instead
                    fatalError("`Server`, `ProtocolType`, `AuthenticationType` properties are mandatory for saving interner password keychaion item")
                }

                attributes.append(KeychainAttribute.server(host))
                attributes.append(KeychainAttribute.protocolType(protocolType))
                attributes.append(KeychainAttribute.authenticationType(authenticationType))

                if let port = server?.port {
                    attributes.append(KeychainAttribute.port(port))
                }

                if let path = server?.path {
                    attributes.append(KeychainAttribute.path(path))
                }

                if let securityDomain = securityDomain {
                    attributes.append(KeychainAttribute.securityDomain(securityDomain))
                }
        }

        return attributes
    }

    var updateRequestAttributes: [KeychainAttribute] {
        [.accessible(accessible), .synchronizable(synchronizable)]
    }
}

extension KeychainKey {
    func updateRequestAttributes(itemClass: ItemClass) -> [Attribute] {
        var attributes = [KeychainAttribute]()

        if let label {
            attributes.append(.label(label))
        }

        if let comment {
            attributes.append(.comment(comment))
        }

        if let aDescription {
            attributes.append(.attrDescription(aDescription))
        }

        if let isInvisible {
            attributes.append(.isInvisible(isInvisible))
        }

        if let isNegative {
            attributes.append(.isNegative(isNegative))
        }

        if case .genericPassword = itemClass, let generic {
            attributes.append(.generic(generic))
        }

        return attributes
    }
}
