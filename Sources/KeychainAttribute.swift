//
// Attribute.swift
//
// Created by Andriy Slyusar on 2022-11-03.
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

protocol Attribute {
    typealias Element = (key: CFString, value: Any)
    var element: Element { get }
}

enum SearchResultAttribute {
    case matchLimit(MatchLimit)

    enum MatchLimit {
        case one
        case all
    }
}

enum ReturnResultAttribute {
    case returnData(Bool)
    case returnAttributes(Bool)
    case returnRef(Bool)
    case returnPersistentRef(Bool)
}

extension KeychainAttribute: Attribute {
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
                return (key: kSecAttrSynchronizable, value: value)
            case .server(let value):
                return (key: kSecAttrServer, value: value)
            case .port(let value):
                return (key: kSecAttrPort, value: value)
            case .protocolType(let value):
                return (key: kSecAttrProtocol, value: value.rawValue)
            case .authenticationType(let value):
                return (key: kSecAttrAuthenticationType, value: value.rawValue)
            case .securityDomain(let value):
                return (key: kSecAttrSecurityDomain, value: value)
            case .path(let value):
                return (key: kSecAttrPath, value: value)
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
            case .creator(let value):
                return (key: kSecAttrCreator, value: value)
            case .type(let value):
                return (key: kSecAttrType, value: value)
            case .creationDate(let value):
                return (key: kSecAttrCreationDate, value: value)
            case .modificationDate(let value):
                return (key: kSecAttrModificationDate, value: value)
        }
    }

    init?(key: String, value: Any) {
        switch key {
            case kSecClass as CFString:
                guard let itemClass = ItemClass(rawValue: value as! CFString) else { return nil }
                self = .class(itemClass)
            case String(kSecAttrService):
                self = .service(value as! String)
            case String(kSecAttrAccessible):
                guard let accessibilityLevel = AccessibilityLevel(rawValue: value as! CFString) else { return nil }
                self = .accessible(accessibilityLevel)
            case String(kSecAttrAccessGroup):
                self = .accessGroup(value as! String)
            case String(kSecAttrSynchronizable):
                guard let synchronizable = Bool(value: value as! CFNumber) else { return nil }
                self = .synchronizable(synchronizable)
            case String(kSecAttrServer):
                self = .server(value as! String)
            case String(kSecAttrPort):
                self = .port(value as! Int)
            case String(kSecAttrProtocol):
                guard let aProtocol = ProtocolType(rawValue: value as! CFString) else { return nil }
                self = .protocolType(aProtocol)
            case String(kSecAttrAuthenticationType):
                guard let authenticationType = AuthenticationType(rawValue: value as! CFString) else { return nil }
                self = .authenticationType(authenticationType)
            case String(kSecAttrSecurityDomain):
                self = .securityDomain(value as! String)
            case String(kSecAttrPath):
                self = .path(value as! String)
            case String(kSecValueData):
                self = .valueData(value as! Data)
            case String(kSecAttrAccount):
                self = .account(value as! String)
            case String(kSecAttrLabel):
                self = .label(value as! String)
            case String(kSecAttrComment):
                self = .comment(value as! String)
            case String(kSecAttrDescription):
                self = .attrDescription(value as! String)
            case String(kSecAttrIsInvisible):
                self = .isInvisible(value as! Bool)
            case String(kSecAttrIsNegative):
                self = .isNegative(value as! Bool)
            case String(kSecAttrGeneric):
                self = .generic(value as! Data)
            case String(kSecAttrCreator):
                self = .creator(value as! String)
            case String(kSecAttrType):
                self = .type(value as! String)
            case String(kSecAttrCreationDate):
                self = .creationDate(value as! Date)
            case String(kSecAttrModificationDate):
                self = .modificationDate(value as! Date)
            default:
                return nil
        }
    }
}

extension Bool {
    init?(value: CFNumber) {
        if value == kCFBooleanTrue { self = true }
        else if value == kCFBooleanFalse { self = false }
        else { return nil }
    }

    var toCFBoolean: CFBoolean {
        self ? kCFBooleanTrue : kCFBooleanFalse
    }
}

/// Query for both synchronizable and non-synchronizable results
struct SynchronizableAnyAttribute: Attribute {
    var element: Element { (key: kSecAttrSynchronizable, value: kSecAttrSynchronizableAny) }
}

extension SearchResultAttribute: Attribute {
    var element: Element {
        switch self {
            case .matchLimit(let matchLimit):
                return (key: kSecMatchLimit, value: matchLimit.rawValue)
        }
    }
}

extension SearchResultAttribute.MatchLimit {
    var rawValue: CFString {
        switch self {
            case .one:
                return kSecMatchLimitOne
            case .all:
                return kSecMatchLimitAll
        }
    }
}

extension ReturnResultAttribute: Attribute {
    var element: Element {
        switch self {
            case .returnData(let value):
                return (key: kSecReturnData, value: value)
            case .returnAttributes(let value):
                return (key: kSecReturnAttributes, value: value)
            case .returnRef(let value):
                return (key: kSecReturnRef, value: value)
            case .returnPersistentRef(let value):
                return (key: kSecReturnPersistentRef, value: value)
        }
    }
}

extension ItemClass {
    init?(rawValue: CFString) {
        switch rawValue {
            case kSecClassGenericPassword:
                self = .genericPassword
            case kSecClassInternetPassword:
                self = .internetPassword
            default:
                return nil
        }
    }

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
    init?(rawValue: CFString) {
        switch rawValue {
            case kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly:
                self = .whenPasscodeSetThisDeviceOnly
            case kSecAttrAccessibleWhenUnlockedThisDeviceOnly:
                self = .unlockedThisDeviceOnly
            case kSecAttrAccessibleWhenUnlocked:
                self = .whenUnlocked
            case kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly:
                self = .afterFirstUnlockThisDeviceOnly
            case kSecAttrAccessibleAfterFirstUnlock:
                self = .afterFirstUnlock
            case kSecAttrAccessibleAlwaysThisDeviceOnly:
                self = .alwaysThisDeviceOnly
            case kSecAttrAccessibleAlways:
                self = .accessibleAlways
            default:
                return nil
        }
    }

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
    init?(rawValue: CFString) {
        switch rawValue {
            case kSecAttrProtocolFTP:
                self = .ftp
            case kSecAttrProtocolFTPAccount:
                self = .ftpAccount
            case kSecAttrProtocolHTTP:
                self = .http
            case kSecAttrProtocolIRC:
                self = .irc
            case kSecAttrProtocolNNTP:
                self = .nntp
            case kSecAttrProtocolPOP3:
                self = .pop3
            case kSecAttrProtocolSMTP:
                self = .smtp
            case kSecAttrProtocolSOCKS:
                self = .socks
            case kSecAttrProtocolIMAP:
                self = .imap
            case kSecAttrProtocolLDAP:
                self = .ldap
            case kSecAttrProtocolAppleTalk:
                self = .appleTalk
            case kSecAttrProtocolAFP:
                self = .afp
            case kSecAttrProtocolTelnet:
                self = .telnet
            case kSecAttrProtocolSSH:
                self = .ssh
            case kSecAttrProtocolFTPS:
                self = .ftps
            case kSecAttrProtocolHTTPS:
                self = .https
            case kSecAttrProtocolHTTPProxy:
                self = .httpProxy
            case kSecAttrProtocolHTTPSProxy:
                self = .httpsProxy
            case kSecAttrProtocolFTPProxy:
                self = .ftpProxy
            case kSecAttrProtocolSMB:
                self = .smb
            case kSecAttrProtocolRTSP:
                self = .rtsp
            case kSecAttrProtocolRTSPProxy:
                self = .rtspProxy
            case kSecAttrProtocolDAAP:
                self = .daap
            case kSecAttrProtocolEPPC:
                self = .eppc
            case kSecAttrProtocolIPP:
                self = .ipp
            case kSecAttrProtocolNNTPS:
                self = .nntps
            case kSecAttrProtocolLDAPS:
                self = .ldaps
            case kSecAttrProtocolTelnetS:
                self = .telnetS
            case kSecAttrProtocolIMAPS:
                self = .imaps
            case kSecAttrProtocolIRCS:
                self = .ircs
            case kSecAttrProtocolPOP3S:
                self = .pop3S
            default:
                return nil
        }
    }

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
    init?(rawValue: CFString) {
        switch rawValue {
            case kSecAttrAuthenticationTypeNTLM:
                self = .ntlm
            case kSecAttrAuthenticationTypeMSN:
                self = .msn
            case kSecAttrAuthenticationTypeDPA:
                self = .dpa
            case kSecAttrAuthenticationTypeRPA:
                self = .rpa
            case kSecAttrAuthenticationTypeHTTPBasic:
                self = .httpBasic
            case kSecAttrAuthenticationTypeHTTPDigest:
                self = .httpDigest
            case kSecAttrAuthenticationTypeHTMLForm:
                self = .htmlForm
            case kSecAttrAuthenticationTypeDefault:
                self = .`default`
            default:
                return nil
        }
    }

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
