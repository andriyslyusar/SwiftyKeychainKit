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
    open func save(key: String, value: T, keychain: Keychain) throws {
        fatalError()
    }

    open func get(key: String, keychain: Keychain) throws -> T? {
        fatalError()
    }
}

open class KeychainBridgeInt: KeychainBridge<Int> {
    open override func save(key: String, value: Int, keychain: Keychain) throws {
        try persist(value: Data(from: value), key: key, keychain: keychain)
    }

    open override func get(key: String, keychain: Keychain) throws -> Int? {
        do {
            guard let data = try find(key: key, keychain: keychain) else {
                return nil
            }
            return data.convert(type: Int.self)
        } catch {
            throw error
        }
    }
}

class KeychainBridgeString: KeychainBridge<String> {
    open override func save(key: String, value: String, keychain: Keychain) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.conversionError
        }

        try persist(value: data, key: key, keychain: keychain)
    }

    open override func get(key: String, keychain: Keychain) throws -> String? {
        do {
            guard let data = try find(key: key, keychain: keychain) else {
                return nil
            }
            return String(data: data, encoding: .utf8)
        } catch {
            throw error
        }
    }
}

class KeychainBridgeCodable<T: Codable>: KeychainBridge<T> {
    open override func save(key: String, value: T, keychain: Keychain) throws {
        let data = try JSONEncoder().encode(value)
        try persist(value: data, key: key, keychain: keychain)
    }

    override func get(key: String, keychain: Keychain) throws -> T? {
        do {
            guard let data = try find(key: key, keychain: keychain) else {
                return nil
            }

            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw error
        }
    }
}

extension KeychainBridge {
    func persist(value: Data, key: String, keychain: Keychain) throws {
        let query: [Attribute] = [
            .class(.genericPassword),
            .service(keychain.service),
            .account(key)
        ]

        let status = Keychain.itemFetch(query)

        switch status {
        case errSecSuccess:
            // Keychain already contains key -> update existing item

            let attributes = keychain.attributes(value: value)

            let status = Keychain.itemUpdate(query, attributes)
            if status != errSecSuccess {
                throw KeychainError(status: status)
            }

        case errSecItemNotFound:
            // Keychain doesn't contain key -> add new item

            let query: Attributes = [
                .class(.genericPassword),
                .accessible(keychain.accessible),
                .service(keychain.service),
                .account(key),
                .valueData(value)
            ]

            let status = Keychain.itemAdd(query)
            if status != errSecSuccess {
                throw KeychainError(status: status)
            }

        case errSecInteractionNotAllowed:
            // This error can happen when your app is launched in the background while the device is locked
            // (for example, in response to an actionable push notification or a Core Location geofence event),
            // the application may crash as a result of accessing a locked keychain entry.
            //
            // TODO: Maybe introduce `force` property to allow remove and save key with different permissions
            throw KeychainError(status: status)

        default:
            throw KeychainError(status: status)
        }
    }

    func find(key: String, keychain: Keychain) throws -> Data? {
        let query: Attributes = [
            .class(.genericPassword),
            .service(keychain.service),
            .account(key),
            .isReturnData(true),
            .matchLimitOne
        ]

        var result: AnyObject?
        let status = 	SecItemCopyMatching(query.compose(), &result)
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw KeychainError.unexpectedError
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError(status: status)
        }
    }
}

/// https://stackoverflow.com/a/38024025/2845836
extension Data {
    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    func convert<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
}


