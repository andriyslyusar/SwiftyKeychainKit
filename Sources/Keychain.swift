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
    /// The kind of data Keychain items hold
    public let itemClass: ItemClass = .genericPassword

    //TODO: Budnle identifier by default
    /// The service associated with Keychain item
    public let service: String

    /// Indicates when your app has access to the data in a Keychain item
    public let accessible: AccessibilityLevel

    /// Keychain items with share access same group
    public let accessGroup: String?
    
    public init(service: String, accessible: AccessibilityLevel = .whenUnlocked, accessGroup: String? = nil) {
        self.service = service
        self.accessible = accessible
        self.accessGroup = accessGroup
    }
    
    public func save<T: KeychainSerializable>(_ value: T.T, key: KeychainKey<T>) throws {
        try T.bridge.save(key: key._key, value: value, keychain: self)
    }
    
    public func get<T: KeychainSerializable>(key: KeychainKey<T>) throws -> T.T? {
        return try T.bridge.get(key: key._key, keychain: self)
    }
    
    public func remove<T: KeychainSerializable>(key: KeychainKey<T>) throws {
        let query = searchQuery([
            .account(key._key)
        ])

        let status = Keychain.itemDelete(query)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError(status: status)
        }
    }
    
    public func removeAll() throws {
        let query = searchQuery()

        let status = Keychain.itemDelete(query)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError(status: status)
        }
    }
}

extension Keychain {
    func searchQuery(_ extraAttributes: Attributes = Attributes()) -> Attributes {
        var query: Attributes = [
            .class(itemClass)
        ]

        switch itemClass {
        case .genericPassword:
            query.append(.service(service))

            // TODO: Access group is not supported on any simulators.
            if let accessGroup = accessGroup {
                query.append(.accessGroup(accessGroup))
            }
        case .internetPassword:
            fatalError("Not yet implemented")
        }

        return query + extraAttributes
    }

    /// Use this method to build attributes to add a new keychain entry
    func addRequestAttributes(value: Data, key: String) -> Attributes {
        var attributes = searchQuery()

        attributes.append(.account(key))
        attributes += updateRequestAttributes(value: value)

        return attributes
    }

    /// Use this method to build attributes to update a new keychain entry
    /// Keychain SecItemUpdate do not allow search query parameters and account to pass as attributes
    func updateRequestAttributes(value: Data) -> Attributes {
        var attributes = Attributes()

        attributes.append(contentsOf: [
            .valueData(value),
            .accessible(accessible),
        ])

        return attributes
    }
}

extension Keychain {
    // TODO: Maybe use global function instead
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
    case accessGroup(String)
    /// Query for both synchronizable and non-synchronizable results.
    case synchronizableAny

    var rawValue: Element {
        switch self {
        case .class(let value):
            return Element(key: kSecClass, value: value.rawValue)
        case .service(let value):
            return Element(key: kSecAttrService, value: value)
        case .account(let value):
            return Element(key: kSecAttrAccount, value: value)
        case .valueData(let data):
            return Element(key: kSecValueData, value: data)
        case .accessible(let level):
            return Element(key: kSecAttrAccessible, value: level.rawValue)
        case .isReturnData(let isReturn):
            let value = isReturn ? kCFBooleanTrue : kCFBooleanFalse
            return Element(key: kSecReturnData, value: value as Any)
        case .matchLimitOne:
            return Element(key: kSecMatchLimit, value: kSecMatchLimitOne)
        case .matchLimitAll:
            return Element(key: kSecMatchLimit, value: kSecMatchLimitAll)
        case .accessGroup(let value):
            return Element(key: kSecAttrAccessGroup, value: value)
        case .synchronizableAny:
            return Element(key: kSecAttrSynchronizable, value: kSecAttrSynchronizableAny)
        }
    }

    struct Element {
        let key: String
        let value: Any

        init(key: CFString, value: Any) {
            self.key = String(key)
            self.value = value
        }
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
