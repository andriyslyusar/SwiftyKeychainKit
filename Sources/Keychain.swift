//
// Keychain.swift
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

@dynamicCallable
public struct Keychain {
    /// Keychain items with share access same group
    public var accessGroup: String?

    public init(accessGroup: String? = nil) {
        self.accessGroup = accessGroup
    }

    /// Persist value for key in keychain
    /// - Parameter value: Persisting value
    /// - Parameter key: Key for value
    public func set<T: KeychainSerializable>(_ value: T, for key: KeychainKey<T>) throws {
        try set(value, forKey: key)
    }

    /// Get value for provided key from keychain
    /// - Parameter key: Key for value
    public func get<T: KeychainSerializable>(_ key: KeychainKey<T>) throws -> T? {
        try get(key: key)
    }

    /// Get value for provided key from keychain, return default value in case `value == nil` and not error raised
    /// - Parameter key: Key for value
    /// - Parameter defaultProvider: Value return by default than value is nil
    public func get<T: KeychainSerializable>(_ key: KeychainKey<T>, default defaultProvider: @autoclosure () -> T) throws -> T {
        do {
            if let value = try get(key: key) {
                return value
            }
            return defaultProvider()
        } catch {
            throw error
        }
    }

    /// Remove key from specific keychain
    /// - Parameter key: Keychain key to remove
    public func remove<T: KeychainSerializable>(_ key: KeychainKey<T>) throws {
        try remove(key: key)
    }

    /// Remove all keys from specific keychain
    public func removeAll() throws {
        try removeAll(ofType: .genericPassword)
        try removeAll(ofType: .internetPassword)
    }

    /// Remove all keys from specific keychain of type
    public func removeAll(ofType type: ItemClass) throws {
        var searchRequestAttributes = [Attribute]()
        searchRequestAttributes += self.searchRequestAttributes
        searchRequestAttributes.append(KeychainAttribute.class(type))
        searchRequestAttributes.append(SynchronizableAnyAttribute())

        let status = keychainItemDelete(searchRequestAttributes)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError(status: status)
        }
    }

    /// Subscript fetching from keychain in return result with Result type
    public subscript<T: KeychainSerializable>(key: KeychainKey<T>) -> Result<T?, KeychainError> {
        do {
            return .success(try get(key))
        } catch {
            return .failure(KeychainError(error))
        }
    }

     /// Subscript with default value. In case of error raise fetching from keychain `.failure` result returns, default
     /// value apply only in case fetch value is nil
    public subscript<T: KeychainSerializable>(key: KeychainKey<T>, default defaultProvider: @autoclosure () -> T) -> Result<T, KeychainError> {
        do {
            return .success(try get(key, default: defaultProvider()))
        } catch {
            return .failure(KeychainError(error))
        }
    }

    /// User `dynamicCallable` syntax sugar to implement `get` keychain value
    ///
    /// NOTE: Current implementation support only single argument and will ignore others.
    ///
    /// Example:
    /// ```
    /// try keychain(.stringKey)
    ///  ```
    /// - Parameter args: KeychainKey object
    public func dynamicallyCall<T: KeychainSerializable>(withArguments args: [KeychainKey<T>]) throws -> T? {
        return try get(args[0])
    }

    /// User `dynamicCallable` syntax sugar to implement `get` keychain value. 
    ///
    /// NOTE: Current implementation support only single argument and will ignore others.
    ///
    /// Due to `ambiguous use of method` error it is required to case return type to `Result`
    /// ```
    /// if case .success(let value) = keychain(key) as Result { ... }
    /// ```
    /// - Parameter args: KeychainKey object
    public func dynamicallyCall<T: KeychainSerializable>(withArguments args: [KeychainKey<T>]) -> Result<T?, KeychainError> {
        do {
            return .success(try get(args[0]))
        } catch {
            return .failure(KeychainError(error))
        }
    }

    /// Get attributes for provided key from keychain
    /// - Parameter key: Key for value
    public func attributes<T: KeychainSerializable>(_ key: KeychainKey<T>) throws -> [KeychainAttribute] {
        try attributes(key: key)
    }
}

public extension Keychain {
    static var `default` = Keychain()
}

private extension Keychain {
    func set<T: KeychainSerializable>(_ value: T, forKey key: KeychainKey<T>) throws {
        let attributesToSearch: [Attribute] = self.searchRequestAttributes
            + key.searchRequestAttributes
            + [KeychainAttribute.account(key.key)]

        let status = keychainItemFetch(attributesToSearch)
        switch status {
            // Keychain already contains key -> update existing item
            case errSecSuccess:
                let attributesToUpdate = key.updateRequestAttributes
                + [KeychainAttribute.valueData(try value.encode())]

                let status = keychainItemUpdate(
                    attributesToSearch: attributesToSearch,
                    attributesToUpdate: attributesToUpdate
                )
                if status != errSecSuccess {
                    throw KeychainError(status: status)
                }

            // Keychain doesn't contain key -> add new item
            case errSecItemNotFound:
                let attributesToAdd = self.searchRequestAttributes
                + key.searchRequestAttributes
                + key.updateRequestAttributes
                + [KeychainAttribute.account(key.key), KeychainAttribute.valueData(try value.encode())]

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

    func get<T: KeychainSerializable>(key: KeychainKey<T>) throws -> T? {
        let attributesToSearch: [Attribute] = self.searchRequestAttributes
            + key.searchRequestAttributes
            + [KeychainAttribute.account(key.key)]
            + [SearchResultAttribute.matchLimit(.one)]
            + [ReturnResultAttribute.returnData(true)]

        var result: AnyObject?
        let status = SecItemCopyMatching(attributesToSearch.compose(), &result)
        switch status {
            case errSecSuccess:
                guard let data = result as? Data else {
                    throw KeychainError.unexpectedError
                }
                return try T.decode(data)

            case errSecItemNotFound:
                return nil

            default:
                throw KeychainError(status: status)
        }
    }

    func attributes<T: KeychainSerializable>(key: KeychainKey<T>) throws -> [KeychainAttribute] {
        let attributesToSearch: [Attribute] = self.searchRequestAttributes
            + key.searchRequestAttributes
            + [KeychainAttribute.account(key.key)]
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
                return data.compactMap { KeychainAttribute(key: $0, value: $1) }

            default:
                throw KeychainError(status: status)
        }
    }

    func remove<T: KeychainSerializable>(key: KeychainKey<T>) throws {
        let attributesToSearch: [Attribute] = self.searchRequestAttributes
            + key.searchRequestAttributes
            + [KeychainAttribute.account(key.key)]

        let status = keychainItemDelete(attributesToSearch)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError(status: status)
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

    /// Build keychain search request attributes
    var searchRequestAttributes: [Attribute] {
        var attributes = [Attribute]()
        accessGroup.flatMap { attributes.append(KeychainAttribute.accessGroup($0)) }
        return attributes
    }
}
