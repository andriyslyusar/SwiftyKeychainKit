# SwiftyKeychainKit

SwiftyKeychainKit is a simple Swift wrapper for Keychain Services API with the benefits of static typing. Define your keys in one place, use value types easily, and get extra safety and convenient compile-time checks for free.

## Features
* Static typing and compile-time checks
* Swift 5 compatible

## Usage

### Basic

```swift
let keychain = Keychain(service: "com.swifty.keychain")
let accessTokenKey = KeychainKey<String>(key: "accessToken")

// Save or modify value
try? keychain.save("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9", key: accessTokenKey)

// Get value 
let value = try? keychain.get(key: accessTokenKey)

// Remove value 
try? keychain.remove(key: accessTokenKey)

// Remove all values 
try? keychain.removeAll()
```

## Supported types
- [x] Int  
- [x] String  
- [ ] Double  
- [ ] Bool  
- [ ] Data  
- [ ] Date  
- [ ] URL  

and more:
- [x] Codable  
- [x] NSCoding  
- [ ] RawRepresentable  

## Supported attributes
- [x] kSecAttrAccessGroup 
- [x] kSecAttrAccessible 
- [ ] kSecAttrCreationDate
- [ ] kSecAttrModificationDate
- [ ] kSecAttrDescription
- [ ] kSecAttrComment
- [ ] kSecAttrCreator
- [ ] kSecAttrType
- [ ] kSecAttrLabel
- [ ] kSecAttrIsInvisible
- [ ] kSecAttrIsNegative
- [x] kSecAttrAccount
- [ ] kSecAttrSynchronizable

**Generic password**
- [ ] kSecAttrAccessControl
- [x] kSecAttrService 
- [ ] kSecAttrGeneric

**Internet password**
- [ ] kSecAttrSecurityDomain
- [ ] kSecAttrServer
- [ ] kSecAttrProtocol
- [ ] kSecAttrAuthenticationType
- [ ] kSecAttrPort
- [ ] kSecAttrPath

## Requirement

Swift ?

Platform | Availability
------------ | -------------
iOS | ?
macOS | ?
tvOS | ? 
watchOS | ?

### Installation
### CocoaPods
TBD  

### Swift Package Manager
TBD

### Carthage
TBD

## Supporting more types
TBD

## Acknowledgement 
* [SwiftyUserDefaults](https://github.com/sunshinejr/SwiftyUserDefaults) - API design inspiration
* [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) - API wrapper knowledge source.

## Author
Andriy Slyusar  
* https://twitter.com/andriyslyusar
* https://github.com/andriyslyusar 

## License

SwiftyKeychainKit is available under the MIT license. See the [LICENSE file](https://github.com/andriyslyusar/SwiftyKeychainKit/blob/master/LICENSE) for more info.