# SwiftyKeychainKit
![Platforms](https://img.shields.io/badge/platforms-ios%20-lightgrey.svg)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg?style=flat)](#cocoapods)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](#swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](#carthage)
![Swift version](https://img.shields.io/badge/swift-5.0%20%7C%205.1-orange.svg)

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
try? keychain.save("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9", for : accessTokenKey)

// Get value 
let value = try keychain.get(accessTokenKey)

// Remove value 
try keychain.remove(accessTokenKey)

// Remove all values 
try keychain.removeAll()
```

### Instantiation

```swift
// Generic password
let keychain = Keychain(service: "com.swifty.keychainkit")

// Internet password
let keychain = Keychain(server: URL(string: "https://www.google.com")!, protocolType: .https)
```

### Define keys 

For extra convenience, define your keys by extending `KeychainKeys` class and adding static properties:

```swift
extension KeychainKeys {
    static let username = KeychainKey<String>(key: "username")
    static let age = KeychainKey<Int>(key: "age")
}
```

and later in the code use shortcut dot syntax:

```swift
// save
try? keychain.save("John Snow", for: .username)

// get
let username = try keychain.get(.username)
```

### Geting values

You can use `subscripts` and `dynamicCallable` syntax sugar to get value as `Result<ValueType, KeychainError>`

```swift
let username = try keychain[.username].get()

// or 

if case .success(let age) = keychain[.age] {
    ...
}
```

```swift
let username = try keychain(.username).get()

// or 

if case .success(let age) = keychain(.age) {
    ...
}
```

Both `subscripts` and `dynamicCallable` syntaxt available only for geting values. Currently Swift language limitation do not allow implement setter with error handling.

### Default values

You can provide default value for get method and it will used than **keychain key is nil** and **no error throw**.

```swift
try keychain.get(.username, default: "Daenerys Targaryen")

// or

try keychain[.age, default: 18].get() 
```

## Supported types
- [x] Int  
- [x] String  
- [x] Double  
- [x] Float
- [x] Bool  
- [x] Data  

and more:
- [x] Codable  
- [x] NSCoding  

## Supported attributes

**Common**
- [x] kSecAttrAccessGroup 
- [x] kSecAttrAccessible 
- [x] kSecAttrDescription
- [x] kSecAttrComment
- [ ] kSecAttrCreator
- [ ] kSecAttrType
- [x] kSecAttrLabel
- [x] kSecAttrIsInvisible
- [x] kSecAttrIsNegative
- [x] kSecAttrAccount
- [x] kSecAttrSynchronizable

**Generic password**
- [ ] kSecAttrAccessControl
- [x] kSecAttrService 
- [ ] kSecAttrGeneric

**Internet password**
- [x] kSecAttrSecurityDomain
- [x] kSecAttrServer
- [x] kSecAttrProtocol
- [x] kSecAttrAuthenticationType
- [x] kSecAttrPort
- [x] kSecAttrPath

## Supporting more types
TBD

## Requirement

**Swift** version **5.0**

Platform     | Availability
------------ | -------------
iOS          | >= 12
macOS        | -
tvOS         | - 
watchOS      | -

### Installation
#### CocoaPods
```ruby
pod 'SwiftyKeychainKit', '1.0.0-beta.2'
```

#### Swift Package Manager
```swift
let package = Package(
    dependencies: [
        .Package(url: "https://github.com/andriyslyusar/SwiftyKeychainKit.git", .exact("1.0.0-beta.2"))
    ]
)
```

#### Carthage
```ruby
github "andriyslyusar/SwiftyKeychainKit" "1.0.0-beta.2"
```

## Acknowledgement 
* [SwiftyUserDefaults](https://github.com/sunshinejr/SwiftyUserDefaults) - API design inspiration
* [KeychainAccess](https://github.com/kishikawakatsumi/KeychainAccess) - API wrapper knowledge source

## Author
Andriy Slyusar  
* https://twitter.com/andriyslyusar
* https://github.com/andriyslyusar 

## License

SwiftyKeychainKit is available under the MIT license. See the [LICENSE file](https://github.com/andriyslyusar/SwiftyKeychainKit/blob/master/LICENSE) for more info.