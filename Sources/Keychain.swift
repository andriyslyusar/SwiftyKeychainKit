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

/**
    Extend this class and add your user defaults keys as static constants so you can use the shortcut dot notation
    (e.g. `Keychain[.yourKey]`)

    Example:
    ```
    extension KeychainKeys {
        static let yourKey = KeychainKey<String>(key: "key")
    }
    ```
*/
open class KeychainKeys {}

open class KeychainKey<ValueType: KeychainSerializable>: KeychainKeys {
    public let key: String

    public init(key: String) {
        self.key = key
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

    /// Only Internet Password attribuite
    public var protocolType: ProtocolType?

    /// Only Internet Password attribuite
    public var authenticationType: AuthenticationType?

    /// Only Internet Password attribuite
    public var securityDomain: String?

    public var label: String?

    public var comment: String?

    public var attrDescription: String?

    /// Indicating the item's visibility
    ///
    /// iOS does not have a general-purpose way to view keychain items, so this propery make sense only with sync
    /// to a Mac via iCloud Keychain, than you might want to make it invisible there.
    ///
    /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrisinvisible)
    public var isInvisible: Bool?

    /// Indicating whether the item has a valid password
    ///
    /// This is useful if your application doesn't want a password for some particular service to be stored in the keychain,
    /// but prefers that it always be entered by the user.
    ///
    /// For more information, see [Keychain Services](https://developer.apple.com/documentation/security/ksecattrisnegative)
    public var isNegative: Bool?

    /// Construct Generic Password Keychain
    public init(service: String,
                accessible: AccessibilityLevel = .whenUnlocked,
                accessGroup: String? = nil,
                synchronizable: Bool = false) {
        self.itemClass = .genericPassword
        self.service = service
        self.accessible = accessible
        self.accessGroup = accessGroup
        self.synchronizable = synchronizable
    }

    /// Construct Internet Password Keychain
    public init(server: URL,
                protocolType: ProtocolType,
                authenticationType: AuthenticationType = .default,
                accessible: AccessibilityLevel = .whenUnlocked,
                accessGroup: String? = nil,
                synchronizable: Bool = false,
                securityDomain: String? = nil) {
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
        try T.bridge.set(value, forKey: key.key, in: self)
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
        let status = Keychain.itemDelete(searchQuery())
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
}

extension Keychain {
    func searchQuery(_ extraAttributes: Attributes = Attributes()) -> Attributes {
        var query: Attributes = [
            .class(itemClass),
            .synchronizable(.any)
        ]

        switch itemClass {
        case .genericPassword:
            guard let service = service else {
                fatalError("`Service` property is mandatory for saving generic password keychaion item")
            }
            query.append(.service(service))

            // TODO: Access group is not supported on any simulators.
            if let accessGroup = accessGroup {
                query.append(.accessGroup(accessGroup))
            }
        case .internetPassword:
            guard let host = server?.host,
                let protocolType = protocolType,
                let authenticationType = authenticationType else {
                fatalError("`Server`, `ProtocolType`, `AuthenticationType` properties are mandatory for saving interner password keychaion item")
            }

            query.append(.server(host))
            query.append(.protocolType(protocolType))
            query.append(.authenticationType(authenticationType))

            if let port = server?.port {
                query.append(.port(port))
            }

            if let path = server?.path {
                query.append(.path(path))
            }

            if let securityDomain = securityDomain {
                query.append(.securityDomain(securityDomain))
            }
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
            .synchronizable(.init(boolValue: synchronizable))
        ])

        if let label = label {
            attributes.append(.label(label))
        }

        if let comment = comment {
            attributes.append(.comment(comment))
        }

        if let description = attrDescription {
            attributes.append(.attrDescription(description))
        }

        if let isInvisible = isInvisible {
            attributes.append(.isInvisible(isInvisible))
        }

        if let isNegative = isNegative {
            attributes.append(.isNegative(isNegative))
        }

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
    case matchLimit(MatchLimit)
    case accessGroup(String)
    case synchronizable(Synchronizable)
    case server(String)
    case port(Int)
    case protocolType(ProtocolType)
    case authenticationType(AuthenticationType)
    case securityDomain(String)
    case path(String)
    case label(String)
    case comment(String)
    case attrDescription(String)
    case isInvisible(Bool)
    case isNegative(Bool)

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
        case .matchLimit(let value):
            return Element(key: kSecMatchLimit, value: value.rawValue)
        case .accessGroup(let value):
            return Element(key: kSecAttrAccessGroup, value: value)
        case .synchronizable(let value):
            return Element(key: kSecAttrSynchronizable, value: value.rawValue)
        case .server(let value):
            return Element(key: kSecAttrServer, value: value)
        case .port(let value):
            return Element(key: kSecAttrPort, value: value)
        case .protocolType(let value):
            return Element(key: kSecAttrAuthenticationType, value: value.rawValue)
        case .authenticationType(let value):
            return Element(key: kSecAttrAuthenticationType, value: value.rawValue)
        case .securityDomain(let value):
            return Element(key: kSecAttrSecurityDomain, value: value)
        case .path(let value):
            return Element(key: kSecAttrPath, value: value)
        case .label(let value):
            return Element(key: kSecAttrLabel, value: value)
        case .comment(let value):
            return Element(key: kSecAttrComment, value: value)
        case .attrDescription(let value):
            return Element(key: kSecAttrDescription, value: value)
        case .isInvisible(let value):
            return Element(key: kSecAttrIsInvisible, value: NSNumber(value: value))
        case .isNegative(let value):
            return Element(key: kSecAttrIsNegative, value: NSNumber(value: value))
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

    enum Synchronizable {
        /// Query for both synchronizable and non-synchronizable results
        case any
        case yes
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

extension Array where Element == Attribute {
    func compose() -> CFDictionary {
        return self
            .map { $0.rawValue }
            .reduce(into: [String: Any]()) { $0[$1.key] = $1.value }
            as CFDictionary
    }
}
