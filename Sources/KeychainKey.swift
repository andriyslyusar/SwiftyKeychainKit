//
// KeychainKey.swift
//
// Created by Andriy Slyusar on 2024-07-13.
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

///  Extend this class and add your user defaults keys as static constants so you can use the shortcut dot notation (e.g. `keychain[.yourKey]`)
///
///  ```
///  extension KeychainKey {
///     static var key1: Keychain.Key<String> { .genericPassword(key: "key1") }
///
///     static var key2: Keychain.Key<String> { .genericPassword(key: "key2", label: "Keychain key label", comment: "Keychain key comment") }
///
///     static var key3: Keychain.Key<String> { .internetPassword(key: "key3", url: URL(string: "https://www.github.com/andriyslyusar/SwiftyKeychainKit/issues")!) }
///
///     static var key4: Keychain.Key<Int> { .internetPassword(key: "key", accessible: .afterFirstUnlock, protocolType: .https, domain: "github.com", path: "/andriyslyusar/SwiftyKeychainKit/issues") }
///  }
///  ```

public protocol KeychainKey: Sendable {}

extension Keychain {
    public enum Key<T: KeychainSerializable>: KeychainKey {
        case genericPassword(GenericPassword)
        case internetPassword(InternetPassword)

        public static func genericPassword(
            key: String,
            service: String = KeychainKeyConfiguration.shared.service,
            accessible: AccessibilityLevel = KeychainKeyConfiguration.shared.accessible,
            synchronizable: Bool = KeychainKeyConfiguration.shared.synchronizable,
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
                    desc: description,
                    isInvisible: isInvisible,
                    isNegative: isNegative,
                    generic: generic,
                    creator: creator,
                    type: type
                )
            )
        }

        public static func internetPassword(
            key: String,
            accessible: AccessibilityLevel = KeychainKeyConfiguration.shared.accessible,
            synchronizable: Bool = KeychainKeyConfiguration.shared.synchronizable,
            protocolType: ProtocolType,
            domain: String,
            port: Int? = nil,
            path: String? = nil,
            authenticationType: AuthenticationType = KeychainKeyConfiguration.shared.authenticationType,
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
                    protocolType: protocolType,
                    domain: domain,
                    port: port,
                    path: path,
                    authenticationType: authenticationType,
                    securityDomain: securityDomain,
                    label: label,
                    comment: comment,
                    desc: description,
                    isInvisible: isInvisible,
                    isNegative: isNegative,
                    creator: creator,
                    type: type
                )
            )
        }

        public static func internetPassword(
            key: String,
            accessible: AccessibilityLevel = KeychainKeyConfiguration.shared.accessible,
            synchronizable: Bool = KeychainKeyConfiguration.shared.synchronizable,
            url: URL,
            authenticationType: AuthenticationType = KeychainKeyConfiguration.shared.authenticationType,
            securityDomain: String? = nil,
            label: String? = nil,
            comment: String? = nil,
            description: String? = nil,
            isInvisible: Bool? = nil,
            isNegative: Bool? = nil,
            creator: String? = nil,
            type: String? = nil
        ) -> Self {
            let protocolType = url.scheme.flatMap(ProtocolType.init(rawValue:)) ?? .https

            let domain = if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                url.host(percentEncoded: false) ?? ""
            } else {
                url.host ?? ""
            }

            let path = if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
                url.path(percentEncoded: false)
            } else {
                url.path
            }

            return .internetPassword(
                .init(
                    key: key,
                    accessible: accessible,
                    synchronizable: synchronizable,
                    protocolType: protocolType,
                    domain: domain,
                    port: url.port,
                    path: path,
                    authenticationType: authenticationType,
                    securityDomain: securityDomain,
                    label: label,
                    comment: comment,
                    desc: description,
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

        public var desc: String? {
            switch self {
                case .genericPassword(let attrs):
                    return attrs.desc
                case .internetPassword(let attrs):
                    return attrs.desc
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

        public var creator: String? {
            switch self {
                case .genericPassword(let attrs):
                    return attrs.creator
                case .internetPassword(let attrs):
                    return attrs.creator
            }
        }

        public var type: String? {
            switch self {
                case .genericPassword(let attrs):
                    return attrs.type
                case .internetPassword(let attrs):
                    return attrs.type
            }
        }
    }
}

public final class KeychainKeyConfiguration {
    public var service: String
    public var accessible: AccessibilityLevel
    public var synchronizable: Bool
    public var authenticationType: AuthenticationType

    public nonisolated(unsafe) static let shared = KeychainKeyConfiguration(
        service: Bundle.main.bundleIdentifier ?? "com.swifty.keychainkit",
        accessible: .whenUnlocked,
        synchronizable: false,
        authenticationType: .default
    )

    private init(
        service: String,
        accessible: AccessibilityLevel,
        synchronizable: Bool,
        authenticationType: AuthenticationType
    ) {
        self.service = service
        self.accessible = accessible
        self.synchronizable = synchronizable
        self.authenticationType = authenticationType
    }
}

public protocol KeychainItem: Sendable {
    var key: String { get }
}

public struct InternetPassword: KeychainItem {
    public let key: String

    /// Indicates when your app has access to the data in a Keychain item
    public var accessible: AccessibilityLevel

    /// Indicates whether the item in question is synchronized to other devices through iCloud
    ///
    /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrsynchronizable/)
    public var synchronizable: Bool

    /// The protocol type of the URL
    public var protocolType: ProtocolType

    /// The server's domain name or IP address of the URL
    public var domain: String

    /// The port number of the URL
    public var port: Int?

    /// The path component of the URL
    public var path: String?

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
    public let desc: String?

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

public struct GenericPassword: Sendable, KeychainItem {
    public let key: String

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
    /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/kSecAttrDescription)
    public let desc: String?

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

public enum ItemClass: Sendable, Equatable {
    /// The value that indicates a Generic password item.
    ///
    /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecclassgenericpassword)
    case genericPassword

    /// The value that indicates an Internet password item.
    ///
    /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecclassinternetpassword)
    case internetPassword
}

public enum AccessibilityLevel: Sendable, Equatable {
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

public enum ProtocolType: Sendable, Equatable {
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

public enum AuthenticationType: Sendable, Equatable {
    case ntlm
    case msn
    case dpa
    case rpa
    case httpBasic
    case httpDigest
    case htmlForm
    case `default`
}

extension GenericPassword {
    init?(key: String, attributes: [KeychainAttribute]) {
        guard
            let accessible = attributes.accessible,
            let synchronizable = attributes.synchronizable,
            let service = attributes.service
        else { return nil }

        self = .init(
            key: key,
            service: service,
            accessible: accessible,
            synchronizable: synchronizable,
            label: attributes.label,
            comment: attributes.comment,
            desc: attributes.attrDescription,
            isInvisible: attributes.isInvisible,
            isNegative: attributes.isNegative,
            generic: attributes.generic,
            creator: attributes.creator,
            type: attributes.type
        )
    }
}

extension InternetPassword {
    init?(key: String, attributes: [KeychainAttribute]) {
        guard
            let accessible = attributes.accessible,
            let synchronizable = attributes.synchronizable,
            let protocolType = attributes.protocolType,
            let domain = attributes.server,
            let authenticationType = attributes.authenticationType
        else { return nil }

        self = .init(
            key: key,
            accessible: accessible,
            synchronizable: synchronizable,
            protocolType: protocolType,
            domain: domain,
            port: attributes.port,
            path: attributes.path,
            authenticationType: authenticationType,
            securityDomain: attributes.securityDomain,
            label: attributes.label,
            comment: attributes.comment,
            desc: attributes.attrDescription,
            isInvisible: attributes.isInvisible,
            isNegative: attributes.isNegative,
            creator: attributes.creator,
            type: attributes.type
        )
    }
}

extension ProtocolType {
    init?(rawValue: String) {
        switch rawValue {
            case "ftp": self = .ftp
            case "ftpaccount": self = .ftpAccount
            case "http": self = .http
            case "irc": self = .irc
            case "nntp": self = .nntp
            case "pop3": self = .pop3
            case "smtp": self = .smtp
            case "socks": self = .socks
            case "imap": self = .imap
            case "ldap": self = .ldap
            case "appletalk": self = .appleTalk
            case "afp": self = .afp
            case "telnet": self = .telnet
            case "ssh": self = .ssh
            case "ftps": self = .ftps
            case "https": self = .https
            case "httpproxy": self = .httpProxy
            case "httpsproxy": self = .httpsProxy
            case "ftpproxy": self = .ftpProxy
            case "smb": self = .smb
            case "rtsp": self = .rtsp
            case "rtspproxy": self = .rtspProxy
            case "daap": self = .daap
            case "eppc": self = .eppc
            case "ipp": self = .ipp
            case "nntps": self = .nntps
            case "ldaps": self = .ldaps
            case "telnets": self = .telnetS
            case "imaps": self = .imaps
            case "ircs": self = .ircs
            case "pop3s": self = .pop3S
            default : return nil
        }
    }
}
