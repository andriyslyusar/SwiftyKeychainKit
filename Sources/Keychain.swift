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
    (e.g. `Keychain[.yourKey]`)

    Example:
    ```
    extension KeychainKeys {
        static let yourKey = KeychainKey<String>(key: "key")

        static let anotherKey = KeychainKey<String>(key: "secret", label: "Keychain key label", comment: "Keychain key comment")
    }
    ```
*/
open class KeychainKeys {}

open class KeychainKey<ValueType: KeychainSerializable>: KeychainKeys {
    public let key: String

    public let attributes: Attributes

    /// Initialise Keychain key with attributes
    /// - Parameter key: Primary item key
    /// - Parameter label: The user-visible label for this item
    /// - Parameter comment: The comment associated with the item
    /// - Parameter description: The item's description
    /// - Parameter isInvisible: Indicating the item's visibility
    /// - Parameter isNegative: Indicating whether the item has a valid password
    /// - Parameter generic: The item's user-defined attribute
    public init(
        key: String,
        label: String? = nil,
        comment: String? = nil,
        description: String? = nil,
        isInvisible: Bool? = nil,
        isNegative: Bool? = nil,
        generic: Data? = nil
    ) {
        self.key = key
        self.attributes = Attributes(
            label: label,
            comment: comment,
            description: description,
            isInvisible: isInvisible,
            isNegative: isNegative,
            generic: generic
        )
    }
}

public extension KeychainKeys {
    struct Attributes {
        /// The user-visible label for this item
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrlabel)
        var label: String?

        /// The comment associated with the item
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrcomment)
        var comment: String?

        /// The item's description
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrcomment)
        var aDescription: String?

        /// Indicating the item's visibility
        ///
        /// iOS does not have a general-purpose way to view keychain items, so this propery make sense only with sync
        /// to a Mac via iCloud Keychain, than you might want to make it invisible there.
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrisinvisible)
        var isInvisible: Bool?

        /// Indicating whether the item has a valid password
        ///
        /// This is useful if your application doesn't want a password for some particular service to be stored in the keychain,
        /// but prefers that it always be entered by the user.
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrisnegative)
        var isNegative: Bool?

        /// The item's user-defined attribute. Items of class GenericPassword have this attribute.
        ///
        /// This is a misterious attribute, by mistake use as primary key on Keychain Service release by developers
        /// https://useyourloaf.com/blog/keychain-duplicate-item-when-adding-password/
        ///
        /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrgeneric)
        var generic: Data?

        init(
            label: String? = nil,
            comment: String? = nil,
            description: String? = nil,
            isInvisible: Bool? = nil,
            isNegative: Bool? = nil,
            generic: Data? = nil
        ) {
            self.label = label
            self.comment = comment
            self.aDescription = description
            self.isInvisible = isInvisible
            self.isNegative = isNegative
            self.generic = generic
        }
    }
}

@dynamicCallable
public struct Keychain {
    /// The kind of data Keychain items hold
    public var itemClass: ItemClass = .genericPassword

    //TODO: Budnle identifier by default
    /// The service associated with Keychain item
    public var service: String?

    /// Indicates when your app has access to the data in a Keychain item
    public var accessible: AccessibilityLevel

    /// Keychain items with share access same group
    public var accessGroup: String?

    public var synchronizable: Bool = false

    /// Extracted from URL attributes:
    /// * `Server` - the server's domain name or IP address,
    /// * `Path` - the path component of the URL,
    /// * `Port` - thg Internet port number
    ///
    /// Exclusive Internet Password attribuite.
    public var server: URL?

    /// Exclusive Internet Password attribuite
    public var protocolType: ProtocolType?

    /// Exclusive Internet Password attribuite
    public var authenticationType: AuthenticationType?

    /// Exclusive Internet Password attribuite
    public var securityDomain: String?

    /// Construct Generic Password Keychain
    public init(
        service: String,
        accessible: AccessibilityLevel = .whenUnlocked,
        accessGroup: String? = nil,
        synchronizable: Bool = false
    ) {
        self.itemClass = .genericPassword
        self.service = service
        self.accessible = accessible
        self.accessGroup = accessGroup
        self.synchronizable = synchronizable
    }

    /// Construct Internet Password Keychain
    public init(
        server: URL,
        protocolType: ProtocolType,
        authenticationType: AuthenticationType = .default,
        accessible: AccessibilityLevel = .whenUnlocked,
        accessGroup: String? = nil,
        synchronizable: Bool = false,
        securityDomain: String? = nil
    ) {
        self.itemClass = .internetPassword
        self.server = server
        self.protocolType = protocolType
        self.authenticationType = authenticationType
        self.accessible = accessible
        self.accessGroup = accessGroup
        self.synchronizable = synchronizable
        self.securityDomain = securityDomain
    }

    /// Persist value for key in Keychain
    /// - Parameter value: Persisting value
    /// - Parameter key: Key for value
    public func set<T: KeychainSerializable>(_ value: T.T, for key: KeychainKey<T>) throws {
        try T.bridge.set(value, forKey: key.key, with: key.attributes, in: self)
    }

    /// Get value for provided key from Keycina,
    /// - Parameter key: Key for value
    public func get<T: KeychainSerializable>(_ key: KeychainKey<T>) throws -> T.T? {
        return try T.bridge.get(key: key.key, from: self)
    }

    /// Get value for provided key from Keycina, return default value in case `value == nil` and not error rised
    /// - Parameter key: Key for value
    /// - Parameter defaultProvider: Value retrun by default than value is nil
    public func get<T: KeychainSerializable>(_ key: KeychainKey<T>,
                                             default defaultProvider: @autoclosure () -> T.T) throws -> T.T {
        do {
            if let value = try T.bridge.get(key: key.key, from: self) {
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
        try T.bridge.remove(key: key.key, from: self)
    }

    /// Remove all keys from specific keychain
    public func removeAll() throws {
        let attributesToSearch: [IAttribute] = searchRequestAttributes

        let status = SecItemDelete(attributesToSearch.compose())
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

//    public subscript(attributes key: String) -> Attributes? {
//        get {
//            return try? get(key) { $0 }
//        }
//    }
}

extension Keychain {
    /// Build keychain search request attributes
    var searchRequestAttributes: [KeychainAttribute] {
        var attributes = [KeychainAttribute]([.class(itemClass), .synchronizable(.any)])

        switch itemClass {
            case .genericPassword:
                guard let service = service else {
                    fatalError("`Service` property is mandatory for saving generic password keychaion item")
                }
                attributes.append(.service(service))

                // TODO: Access group is not supported on any simulators.
                if let accessGroup {
                    attributes.append(.accessGroup(accessGroup))
                }

            case .internetPassword:
                guard
                    let host = server?.host,
                    let protocolType = protocolType,
                    let authenticationType = authenticationType
                else {
                    fatalError("`Server`, `ProtocolType`, `AuthenticationType` properties are mandatory for saving interner password keychaion item")
                }

                attributes.append(.server(host))
                attributes.append(.protocolType(protocolType))
                attributes.append(.authenticationType(authenticationType))

                if let port = server?.port {
                    attributes.append(.port(port))
                }

                if let path = server?.path {
                    attributes.append(.path(path))
                }

                if let securityDomain = securityDomain {
                    attributes.append(.securityDomain(securityDomain))
                }
        }

        return attributes
    }

    var updateRequestAttributes: [KeychainAttribute] {
        [.accessible(accessible), .synchronizable(.init(boolValue: synchronizable))]
    }
}

extension KeychainKeys.Attributes {
    func updateRequestAttributes(itemClass: ItemClass) -> [IAttribute] {
        var attributes = [KeychainKeyAttribute]()

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

typealias Attributes = Array<IAttribute>

protocol IAttribute {
    typealias Element = (key: CFString, value: Any)

    var element: Element { get }
}

enum SearchResultAttribute: IAttribute {
    case matchLimit(MatchLimit)

    var element: Element {
        switch self {
            case .matchLimit(let matchLimit):
                return (key: kSecMatchLimit, value: matchLimit.rawValue)
        }
    }

    enum MatchLimit {
        case one
        case all

        var rawValue: CFString {
            switch self {
                case .one:
                    return kSecMatchLimitOne
                case .all:
                    return kSecMatchLimitAll
            }
        }
    }
}

enum ReturnResultAttribute: IAttribute {
    case returnData(Bool)
    case returnAttributes(Bool)

    var element: Element {
        switch self {
            case .returnData(let value):
                return (key: kSecReturnData, value: value)
            case .returnAttributes(let value):
                return (key: kSecReturnAttributes, value: value)
        }
    }
}

enum KeychainKeyAttribute: IAttribute {
    case valueData(Data)
    case account(String)
    case label(String)
    case comment(String)
    case attrDescription(String)
    case isInvisible(Bool)
    case isNegative(Bool)
    case generic(Data)

    var element: Element {
        switch self {
            case .valueData(let data):
                return (key: kSecValueData, value: data)
            case .account(let value):
                return (key: kSecAttrAccount, value: value)
            case .label(let value):
                return (key: kSecAttrLabel, value: value)
            case .comment(let value):
                return (key: kSecAttrComment, value: value)
            case .attrDescription(let value):
                return (key: kSecAttrDescription, value: value)
            case .isInvisible(let value):
                return (key: kSecAttrIsInvisible, value: NSNumber(value: value))
            case .isNegative(let value):
                return (key: kSecAttrIsNegative, value: NSNumber(value: value))
            case .generic(let value):
                return (key: kSecAttrGeneric, value: value)
        }
    }
}

enum KeychainAttribute: IAttribute {
    case `class`(ItemClass)
    case service(String)
    case accessible(AccessibilityLevel)
    case accessGroup(String)
    case synchronizable(Synchronizable)
    case server(String)
    case port(Int)
    case protocolType(ProtocolType)
    case authenticationType(AuthenticationType)
    case securityDomain(String)
    case path(String)

    var element: Element {
        switch self {
            case .class(let value):
                return (key: kSecClass, value: value.rawValue)
            case .service(let value):
                return (key: kSecAttrService, value: value)
            case .accessible(let level):
                return (key: kSecAttrAccessible, value: level.rawValue)
            case .accessGroup(let value):
                return (key: kSecAttrAccessGroup, value: value)
            case .synchronizable(let value):
                return (key: kSecAttrSynchronizable, value: value.rawValue)
            case .server(let value):
                return (key: kSecAttrServer, value: value)
            case .port(let value):
                return (key: kSecAttrPort, value: value)
            case .protocolType(let value):
                return (key: kSecAttrAuthenticationType, value: value.rawValue)
            case .authenticationType(let value):
                return (key: kSecAttrAuthenticationType, value: value.rawValue)
            case .securityDomain(let value):
                return (key: kSecAttrSecurityDomain, value: value)
            case .path(let value):
                return (key: kSecAttrPath, value: value)
        }
    }

    enum Synchronizable {
        /// Query for both synchronizable and non-synchronizable results
        case any
        /// Query for synchronizable results
        case yes
        /// Query for non-synchronizable results
        case no

        var rawValue: AnyObject {
            switch self {
                case .any:
                    return kSecAttrSynchronizableAny
                case .yes:
                    return kCFBooleanTrue
                case .no:
                    return kCFBooleanFalse
            }
        }

        init(boolValue: Bool) {
            self = boolValue ? Synchronizable.yes : Synchronizable.no
        }
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

extension ItemClass {
    var rawValue: CFString {
        switch self {
            case .genericPassword:
                return kSecClassGenericPassword
            case .internetPassword:
                return kSecClassInternetPassword
            }
    }
}

extension AccessibilityLevel {
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

extension ProtocolType {
    var rawValue: String {
        switch self {
            case .ftp:
                return String(kSecAttrProtocolFTP)
            case .ftpAccount:
                return String(kSecAttrProtocolFTPAccount)
            case .http:
                return String(kSecAttrProtocolHTTP)
            case .irc:
                return String(kSecAttrProtocolIRC)
            case .nntp:
                return String(kSecAttrProtocolNNTP)
            case .pop3:
                return String(kSecAttrProtocolPOP3)
            case .smtp:
                return String(kSecAttrProtocolSMTP)
            case .socks:
                return String(kSecAttrProtocolSOCKS)
            case .imap:
                return String(kSecAttrProtocolIMAP)
            case .ldap:
                return String(kSecAttrProtocolLDAP)
            case .appleTalk:
                return String(kSecAttrProtocolAppleTalk)
            case .afp:
                return String(kSecAttrProtocolAFP)
            case .telnet:
                return String(kSecAttrProtocolTelnet)
            case .ssh:
                return String(kSecAttrProtocolSSH)
            case .ftps:
                return String(kSecAttrProtocolFTPS)
            case .https:
                return String(kSecAttrProtocolHTTPS)
            case .httpProxy:
                return String(kSecAttrProtocolHTTPProxy)
            case .httpsProxy:
                return String(kSecAttrProtocolHTTPSProxy)
            case .ftpProxy:
                return String(kSecAttrProtocolFTPProxy)
            case .smb:
                return String(kSecAttrProtocolSMB)
            case .rtsp:
                return String(kSecAttrProtocolRTSP)
            case .rtspProxy:
                return String(kSecAttrProtocolRTSPProxy)
            case .daap:
                return String(kSecAttrProtocolDAAP)
            case .eppc:
                return String(kSecAttrProtocolEPPC)
            case .ipp:
                return String(kSecAttrProtocolIPP)
            case .nntps:
                return String(kSecAttrProtocolNNTPS)
            case .ldaps:
                return String(kSecAttrProtocolLDAPS)
            case .telnetS:
                return String(kSecAttrProtocolTelnetS)
            case .imaps:
                return String(kSecAttrProtocolIMAPS)
            case .ircs:
                return String(kSecAttrProtocolIRCS)
            case .pop3S:
                return String(kSecAttrProtocolPOP3S)
        }
    }

    public var description: String {
        switch self {
            case .ftp:
                return "FTP"
            case .ftpAccount:
                return "FTPAccount"
            case .http:
                return "HTTP"
            case .irc:
                return "IRC"
            case .nntp:
                return "NNTP"
            case .pop3:
                return "POP3"
            case .smtp:
                return "SMTP"
            case .socks:
                return "SOCKS"
            case .imap:
                return "IMAP"
            case .ldap:
                return "LDAP"
            case .appleTalk:
                return "AppleTalk"
            case .afp:
                return "AFP"
            case .telnet:
                return "Telnet"
            case .ssh:
                return "SSH"
            case .ftps:
                return "FTPS"
            case .https:
                return "HTTPS"
            case .httpProxy:
                return "HTTPProxy"
            case .httpsProxy:
                return "HTTPSProxy"
            case .ftpProxy:
                return "FTPProxy"
            case .smb:
                return "SMB"
            case .rtsp:
                return "RTSP"
            case .rtspProxy:
                return "RTSPProxy"
            case .daap:
                return "DAAP"
            case .eppc:
                return "EPPC"
            case .ipp:
                return "IPP"
            case .nntps:
                return "NNTPS"
            case .ldaps:
                return "LDAPS"
            case .telnetS:
                return "TelnetS"
            case .imaps:
                return "IMAPS"
            case .ircs:
                return "IRCS"
            case .pop3S:
                return "POP3S"
        }
    }
}

extension AuthenticationType {
    var rawValue: String {
        switch self {
            case .ntlm:
                return String(kSecAttrAuthenticationTypeNTLM)
            case .msn:
                return String(kSecAttrAuthenticationTypeMSN)
            case .dpa:
                return String(kSecAttrAuthenticationTypeDPA)
            case .rpa:
                return String(kSecAttrAuthenticationTypeRPA)
            case .httpBasic:
                return String(kSecAttrAuthenticationTypeHTTPBasic)
            case .httpDigest:
                return String(kSecAttrAuthenticationTypeHTTPDigest)
            case .htmlForm:
                return String(kSecAttrAuthenticationTypeHTMLForm)
            case .`default`:
                return String(kSecAttrAuthenticationTypeDefault)
        }
    }

    public var description: String {
        switch self {
            case .ntlm:
                return "NTLM"
            case .msn:
                return "MSN"
            case .dpa:
                return "DPA"
            case .rpa:
                return "RPA"
            case .httpBasic:
                return "HTTPBasic"
            case .httpDigest:
                return "HTTPDigest"
            case .htmlForm:
                return "HTMLForm"
            case .`default`:
                return "Default"
        }
    }
}

extension [IAttribute] {
    func compose() -> CFDictionary {
        return self.map(\.element).reduce(into: [CFString: Any]()) { $0[$1.key] = $1.value } as CFDictionary
    }
}
