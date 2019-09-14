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
import Security

public enum ItemClass {
    /// The value that indicates a generic password item. https://developer.apple.com/documentation/security/ksecclassgenericpassword
    case genericPassword

    /// The value that indicates an Internet password item. https://developer.apple.com/documentation/security/ksecclassinternetpassword
    case internetPassword

    var rawValue: CFString {
        switch self {
        case .genericPassword:
            return kSecClassGenericPassword
        case .internetPassword:
            return kSecClassInternetPassword
        }
    }
}

public enum AccessibilityLevel {
    /// The data in the keychain can only be accessed when the device is unlocked.
    /// Only available if a passcode is set on the device.
    case whenPasscodeSetThisDeviceOnly
    
    /// The data in the keychain item can be accessed only while the device is unlocked by the user.
    case unlockedThisDeviceOnly
    
    /// The data in the keychain item can be accessed only while the device is unlocked by the user.
    case whenUnlocked
    
    /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
    case afterFirstUnlockThisDeviceOnly
    
    /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
    case afterFirstUnlock
    
    /// The data in the keychain item can always be accessed regardless of whether the device is locked.
    @available(iOS, deprecated: 12.0, message: "This is not recommended for application use. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.")
    case alwaysThisDeviceOnly
    
    /// The data in the keychain item can always be accessed regardless of whether the device is locked.
    @available(iOS, deprecated: 12.0, message: "This is not recommended for application use. Items with this attribute migrate to a new device when using encrypted backups.")
    case accessibleAlways
    
    var rawValue: CFString {
        switch self {
        case .whenPasscodeSetThisDeviceOnly:
            return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .unlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .alwaysThisDeviceOnly:
            return kSecAttrAccessibleAlwaysThisDeviceOnly
        case .accessibleAlways:
            return kSecAttrAccessibleAlways
        }
    }
}

public struct Keychain {
    public let itemClass: ItemClass = .genericPassword

    //TODO: Budnle identifier by default
    public let service: String
    
    public let accessible: AccessibilityLevel
    
    public init(service: String, accessible: AccessibilityLevel = .whenUnlocked) {
        self.service = service
        self.accessible = accessible
    }
    
    public func save<T: KeychainSerializable>(_ value: T.T, key: KeychainKey<T>) throws {
        try T.bridge.save(key: key._key, value: value, keychain: self)
    }
    
    public func get<T: KeychainSerializable>(key: KeychainKey<T>) throws -> T.T? {
        return try T.bridge.get(key: key._key, keychain: self)
    }
    
    public func remove<T: KeychainSerializable>(key: KeychainKey<T>) throws {
        let query: [Attribute] = [
            .class(itemClass),
            .service(service),
            .account(key._key)
        ]

        let status = Keychain.itemDelete(query)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError(status: status)
        }
    }
    
    public func removeAll() throws {
        let query: Attributes = [
            .class(itemClass),
            .service(service)
        ]

        let status = Keychain.itemDelete(query)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError(status: status)
        }
    }
}

extension Keychain {
    func baseQuery() -> Attributes {
        let query: Attributes = [
            .class(itemClass),
            .service(service)
        ]

        return query
    }

    func attributes(value: Data) -> Attributes {
        let attributes: Attributes = [
            .valueData(value)
        ]

        return attributes
    }
}

extension Keychain {
    //TODO: Maybe use global function instead
    static func itemDelete(_ query: Attributes) -> OSStatus {
        return SecItemDelete(query.compose())
    }

    static func itemAdd(_ query: Attributes) -> OSStatus {
        return SecItemAdd(query.compose(), nil)
    }

    static func itemUpdate(_ query: Attributes, _ attributes: Attributes) -> OSStatus {
        return SecItemUpdate(query.compose(), attributes.compose())
    }

    static func itemFetch(_ query: Attributes) -> OSStatus {
        return SecItemCopyMatching(query.compose(), nil)
    }
}

typealias Attributes = Array<Attribute>

enum Attribute {
    case `class`(ItemClass)
    case service(String)
    case account(String)
    case valueData(Data)
    case accessible(AccessibilityLevel)
    case isReturnData(Bool)
    case matchLimitOne
    case matchLimitAll

    var rawValue: Element {
        switch self {
        case .class(let value):
            return Element(key: String(kSecClass), value: value.rawValue)
        case .service(let value):
            return Element(key: String(kSecAttrService), value: value)
        case .account(let value):
            return Element(key: String(kSecAttrAccount), value: value)
        case .valueData(let data):
            return Element(key: String(kSecValueData), value: data)
        case .accessible(let level):
            return Element(key: String(kSecAttrAccessible), value: level.rawValue)
        case .isReturnData(let isReturn):
            let value = isReturn ? kCFBooleanTrue : kCFBooleanFalse
            return Element(key: String(kSecReturnData), value: value as Any)
        case .matchLimitOne:
            return Element(key: String(kSecMatchLimit), value: kSecMatchLimitOne)
        case .matchLimitAll:
            return Element(key: String(kSecMatchLimit), value: kSecMatchLimitAll)
        }
    }

    struct Element {
        let key: String
        let value: Any
    }
}

extension Array where Element == Attribute {
    func compose() -> CFDictionary {
        return self
            .map { $0.rawValue }
            .reduce(into: [String: Any]()) { $0[$1.key] = $1.value }
            as CFDictionary
    }
}
