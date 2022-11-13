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

/**
    Extend this class and add your user defaults keys as static constants so you can use the shortcut dot notation
    (e.g. `keychain[.yourKey]`)

    Example:
    ```
    extension KeychainKeys {
        static let yourKey = KeychainKey<String>(key: "key")

        static let anotherKey = KeychainKey<String>(key: "secret", label: "Keychain key label", comment: "Keychain key comment")
    }
    ```
*/

public protocol KeychainKeys {}

public enum KeychainKey<ValueType: KeychainSerializable>: KeychainKeys {
    case genericPassword(GenericPassword)
    case internetPassword(InternetPassword)

    public static func genericPassword(
        key: String,
        service: String,
        accessible: AccessibilityLevel = .whenUnlocked,
        synchronizable: Bool = false,
        label: String? = nil,
        comment: String? = nil,
        description: String? = nil,
        isInvisible: Bool? = nil,
        isNegative: Bool? = nil,
        generic: Data? = nil,
        creator: String? = nil,
        type: String? = nil
    ) -> Self {
        self.genericPassword(
            .init(
                key: key,
                service: service,
                accessible: accessible,
                synchronizable: synchronizable,
                label: label,
                comment: comment,
                descr: description,
                isInvisible: isInvisible,
                isNegative: isNegative,
                generic: generic,
                creator: creator,
                type: type
            )
        )
    }

    /// url - must containse host and correct scheme, othervise will generate run-time error
    public static func internetPassword(
        key: String,
        accessible: AccessibilityLevel = .whenUnlocked,
        synchronizable: Bool = false,
        url: URL,
        scheme: ProtocolType,
        authenticationType: AuthenticationType,
        securityDomain: String? = nil,
        label: String? = nil,
        comment: String? = nil,
        description: String? = nil,
        isInvisible: Bool? = nil,
        isNegative: Bool? = nil,
        creator: String? = nil,
        type: String? = nil
    ) -> Self {
        self.internetPassword(
            .init(
                key: key,
                accessible: accessible,
                synchronizable: synchronizable,
                url: url,
                scheme: scheme,
                authenticationType: authenticationType,
                securityDomain: securityDomain,
                label: label,
                comment: comment,
                descr: description,
                isInvisible: isInvisible,
                isNegative: isNegative,
                creator: creator,
                type: type
            )
        )
    }

    public var key: String {
        switch self {
            case .genericPassword(let attrs):
                return attrs.key
            case .internetPassword(let attrs):
                return attrs.key
        }
    }

    public var accessible: AccessibilityLevel {
        switch self {
            case .genericPassword(let attrs):
                return attrs.accessible
            case .internetPassword(let attrs):
                return attrs.accessible
        }
    }

    public var synchronizable: Bool {
        switch self {
            case .genericPassword(let attrs):
                return attrs.synchronizable
            case .internetPassword(let attrs):
                return attrs.synchronizable
        }
    }

    public var label: String? {
        switch self {
            case .genericPassword(let attrs):
                return attrs.label
            case .internetPassword(let attrs):
                return attrs.label
        }
    }

    public var comment: String? {
        switch self {
            case .genericPassword(let attrs):
                return attrs.comment
            case .internetPassword(let attrs):
                return attrs.comment
        }
    }

    public var descr: String? {
        switch self {
            case .genericPassword(let attrs):
                return attrs.descr
            case .internetPassword(let attrs):
                return attrs.descr
        }
    }

    public var isInvisible: Bool? {
        switch self {
            case .genericPassword(let attrs):
                return attrs.isInvisible
            case .internetPassword(let attrs):
                return attrs.isInvisible
        }
    }

    public var isNegative: Bool? {
        switch self {
            case .genericPassword(let attrs):
                return attrs.isNegative
            case .internetPassword(let attrs):
                return attrs.isNegative
        }
    }

    // TODO: We can set and get String for this property, but according to spec we should use CFNumberRef.
    public var creator: String? {
        switch self {
            case .genericPassword(let attrs):
                return attrs.creator
            case .internetPassword(let attrs):
                return attrs.creator
        }
    }

    // TODO: We can set and get String for this property, but according to spec we should use CFNumberRef.
    public var type: String? {
        switch self {
            case .genericPassword(let attrs):
                return attrs.type
            case .internetPassword(let attrs):
                return attrs.type
        }
    }


    public struct GenericPassword {
        public let key: String

        //TODO: Budnle identifier by default
        /// The service associated with Keychain item
        public var service: String

        /// Indicates when your app has access to the data in a Keychain item
        public var accessible: AccessibilityLevel

        /// Indicates whether the item in question is synchronized to other devices through iCloud
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrsynchronizable/)
        public var synchronizable: Bool

        /// The user-visible label for this item
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrlabel)
        public let label: String?

        /// The comment associated with the item
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrcomment)
        public let comment: String?

        /// The item's description
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrcomment)
        public let descr: String?

        /// Indicating the item's visibility
        ///
        /// iOS does not have a general-purpose way to view keychain items, so this propery make sense only with sync
        /// to a Mac via iCloud Keychain, than you might want to make it invisible there.
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrisinvisible)
        public let isInvisible: Bool?

        /// Indicating whether the item has a valid password
        ///
        /// This is useful if your application doesn't want a password for some particular service to be stored in the keychain,
        /// but prefers that it always be entered by the user.
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrisnegative)
        public let isNegative: Bool?

        /// TBD
        public let generic: Data?

        /// Indicating  the item's creator attribute
        ///
        /// You use this key to set or get a value of type CFNumberRef that represents the item's creator.
        /// This number is the unsigned integer representation of a four-character code (e.g., 'aCrt').
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrcreator)
        public let creator: String?

        /// Indicating the type of secret associated with the query
        ///
        /// You use this key to set or get a value of type CFNumberRef that represents the item's type.
        /// This number is the unsigned integer representation of a four-character code (e.g., 'aTyp').
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrtype)
        public let type: String?
    }

    public struct InternetPassword {
        public let key: String

        /// Indicates when your app has access to the data in a Keychain item
        public var accessible: AccessibilityLevel

        /// Indicates whether the item in question is synchronized to other devices through iCloud
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrsynchronizable/)
        public var synchronizable: Bool

        /// Exclusive Internet Password attribuite
        /// Extracted from URL attributes:
        /// * `Server` - the server's domain name or IP address,
        /// * `Path` - the path component of the URL,
        /// * `Port` - the port number
        /// * `Protocol`- the protocol
        public var url: URL

        // TODO: extract scheme from URL, but temporarily provide explicit
        public var scheme: ProtocolType

        /// Exclusive Internet Password attribuite
        public var authenticationType: AuthenticationType

        /// Exclusive Internet Password attribuite
        public var securityDomain: String?

        /// The user-visible label for this item
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrlabel)
        public let label: String?

        /// The comment associated with the item
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrcomment)
        public let comment: String?

        /// The item's description
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrcomment)
        public let descr: String?

        /// Indicating the item's visibility
        ///
        /// iOS does not have a general-purpose way to view keychain items, so this propery make sense only with sync
        /// to a Mac via iCloud Keychain, than you might want to make it invisible there.
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrisinvisible)
        public let isInvisible: Bool?

        /// Indicating whether the item has a valid password
        ///
        /// This is useful if your application doesn't want a password for some particular service to be stored in the keychain,
        /// but prefers that it always be entered by the user.
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrisnegative)
        public let isNegative: Bool?

        /// Indicating  the item's creator attribute
        ///
        /// You use this key to set or get a value of type CFNumberRef that represents the item's creator.
        /// This number is the unsigned integer representation of a four-character code (e.g., 'aCrt').
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrcreator)
        public let creator: String?

        /// Indicating the type of secret associated with the query
        ///
        /// You use this key to set or get a value of type CFNumberRef that represents the item's type.
        /// This number is the unsigned integer representation of a four-character code (e.g., 'aTyp').
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrtype)
        public let type: String?
    }
}

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
    public func set<T: KeychainSerializable>(_ value: T.T, for key: KeychainKey<T>) throws {
        try T.bridge.set(value, forKey: key, in: self)
    }

    /// Get value for provided key from keychain
    /// - Parameter key: Key for value
    public func get<T: KeychainSerializable>(_ key: KeychainKey<T>) throws -> T.T? {
        return try T.bridge.get(key: key, from: self)
    }

    /// Get value for provided key from Keycina, return default value in case `value == nil` and not error rised
    /// - Parameter key: Key for value
    /// - Parameter defaultProvider: Value retrun by default than value is nil
    public func get<T: KeychainSerializable>(
        _ key: KeychainKey<T>,
        default defaultProvider: @autoclosure () -> T.T
    ) throws -> T.T {
        do {
            if let value = try T.bridge.get(key: key, from: self) {
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
        try T.bridge.remove(key: key, from: self)
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

    /// Subsript fetching from keychain in return result with Result type
    public subscript<T: KeychainSerializable>(key: KeychainKey<T>) -> Result<T.T?, KeychainError> {
        do {
            return .success(try get(key))
        } catch {
            return .failure(KeychainError(error))
        }
    }

     /// Subsript with defaul value. In case of error raise fetchin from keychain `.failure` result returns, default
     /// value apply only in case fetch value is nil
    public subscript<T: KeychainSerializable>(key: KeychainKey<T>, default defaultProvider: @autoclosure () -> T.T)
        -> Result<T.T, KeychainError> {

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
    public func dynamicallyCall<T: KeychainSerializable>(withArguments args: [KeychainKey<T>]) throws -> T.T? {
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
    public func dynamicallyCall<T: KeychainSerializable>(withArguments args: [KeychainKey<T>]) -> Result<T.T?, KeychainError> {
        do {
            return .success(try get(args[0]))
        } catch {
            return .failure(KeychainError(error))
        }
    }

    /// Get attributes for provided key from keychain
    /// - Parameter key: Key for value
    public func attributes<T: KeychainSerializable>(_ key: KeychainKey<T>) throws -> [KeychainAttribute] {
        try T.bridge.attributes(key: key, from: self)
    }
}

public enum KeychainAttribute: Equatable {
    // TODO: Maybe rename `class` to type
    case `class`(ItemClass)
    case service(String)
    case accessible(AccessibilityLevel)
    case accessGroup(String)
    case synchronizable(Bool)
    case server(String)
    case port(Int)
    case protocolType(ProtocolType)
    case authenticationType(AuthenticationType)
    case securityDomain(String)
    case path(String)
    case valueData(Data)
    case account(String)
    case label(String)
    case comment(String)
    case attrDescription(String)
    case isInvisible(Bool)
    case isNegative(Bool)
    case generic(Data)
    case creator(String)
    case type(String)
}

public extension [KeychainAttribute] {
    var `class`: ItemClass? {
        self.compactMap { if case let .class(value) = $0 { return value } else { return nil } }.first
    }

    var service: String? {
        self.compactMap { if case let .service(value) = $0 { return value } else { return nil } }.first
    }

    var accessible: AccessibilityLevel? {
        self.compactMap { if case let .accessible(value) = $0 { return value } else { return nil } }.first
    }

    var accessGroup: String? {
        self.compactMap { if case let .accessGroup(value) = $0 { return value } else { return nil } }.first
    }

    var synchronizable: Bool? {
        self.compactMap { if case let .synchronizable(value) = $0 { return value } else { return nil } }.first
    }

    var server: String? {
        self.compactMap { if case let .server(value) = $0 { return value } else { return nil } }.first
    }

    var port: Int? {
        self.compactMap { if case let .port(value) = $0 { return value } else { return nil } }.first
    }

    var protocolType: ProtocolType? {
        self.compactMap { if case let .protocolType(value) = $0 { return value } else { return nil } }.first
    }

    var authenticationType: AuthenticationType? {
        self.compactMap { if case let .authenticationType(value) = $0 { return value } else { return nil } }.first
    }

    var securityDomain: String? {
        self.compactMap { if case let .securityDomain(value) = $0 { return value } else { return nil } }.first
    }

    var path: String? {
        self.compactMap { if case let .path(value) = $0 { return value } else { return nil } }.first
    }

    var valueData: Data? {
        self.compactMap { if case let .valueData(value) = $0 { return value } else { return nil } }.first
    }

    var account: String? {
        self.compactMap { if case let .account(value) = $0 { return value } else { return nil } }.first
    }

    var label: String? {
        self.compactMap { if case let .label(value) = $0 { return value } else { return nil } }.first
    }

    var comment: String? {
        self.compactMap { if case let .comment(value) = $0 { return value } else { return nil } }.first
    }

    var attrDescription: String? {
        self.compactMap { if case let .attrDescription(value) = $0 { return value } else { return nil } }.first
    }

    var isInvisible: Bool? {
        self.compactMap { if case let .isInvisible(value) = $0 { return value } else { return nil } }.first
    }

    var isNegative: Bool? {
        self.compactMap { if case let .isNegative(value) = $0 { return value } else { return nil } }.first
    }

    var generic: Data? {
        self.compactMap { if case let .generic(value) = $0 { return value } else { return nil } }.first
    }

    var creator: String? {
        self.compactMap { if case let .creator(value) = $0 { return value } else { return nil } }.first
    }

    var type: String? {
        self.compactMap { if case let .type(value) = $0 { return value } else { return nil } }.first
    }
}

public enum ItemClass {
    /// The value that indicates a Generic password item.
    ///
    /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecclassgenericpassword)
    case genericPassword

    /// The value that indicates an Internet password item.
    ///
    /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecclassinternetpassword)
    case internetPassword
}

public enum AccessibilityLevel {
    /// The data in the keychain can only be accessed when the device is unlocked.
    /// Only available if a passcode is set on the device
    ///
    ///  For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattraccessiblewhenpasscodesetthisdeviceonly)
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
}

public enum ProtocolType {
    case ftp
    case ftpAccount
    case http
    case irc
    case nntp
    case pop3
    case smtp
    case socks
    case imap
    case ldap
    case appleTalk
    case afp
    case telnet
    case ssh
    case ftps
    case https
    case httpProxy
    case httpsProxy
    case ftpProxy
    case smb
    case rtsp
    case rtspProxy
    case daap
    case eppc
    case ipp
    case nntps
    case ldaps
    case telnetS
    case imaps
    case ircs
    case pop3S
}

public enum AuthenticationType {
    case ntlm
    case msn
    case dpa
    case rpa
    case httpBasic
    case httpDigest
    case htmlForm
    case `default`
}
