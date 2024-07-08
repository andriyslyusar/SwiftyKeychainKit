# SwiftyKeychainKit

![Platforms](https://img.shields.io/badge/platforms-ios%20-lightgrey.svg)
[![Build Status](https://github.com/andriyslyusar/SwiftyKeychainKit/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/andriyslyusar/SwiftyKeychainKit/actions)
![Swift version](https://img.shields.io/badge/swift-5.7%20%7C%205.6-orange.svg)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](#swift-package-manager)

SwiftyKeychainKit is a simple Swift wrapper for Keychain Services API with the benefits of static typing. Define your keys in one place, use value types easily, and get extra safety and convenient compile-time checks for free.

## Features
* Static typing and compile-time checks
* Support Gereric and Internet passwords
* Throwing and Result type get methods
* Easy way to implement support for custom types

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

## SwiftUI

### Basic
Use @AppKeychainStorage property wrapper for storing and reading values from Keychain, which will automatically reinvoke your view’s body property when the value changes. 
* AppKeychainStorage property wrapper DOES NOT watches a key in KeyChain, and will not refresh your UI if that key changes. (Keychain on iOS lucking API to implement obsevation)
* AppKeychainStorage property wrapper DOES NOT implement "projected value" Binding. The main reason is Swift lucking feature to implement throwable 'set', ...

```swift
struct YourView: View {
    @AppKeychainStorage(.secret) var secret

    @State var secretInput: String = ""

    var body: some View {
        // Get value 
        switch secret {
            case .success(let value):
                if let value = value {
                    Text("Keychain value: \(value)")
                } else {
                    Text("Keychain missing value")
                }

            case .failure(let error):
                Text("Keychain error: \(error)")
        }

        // Set value
        TextField("Input secret", text: $secretInput)
        Button("Save") {
            do {
                try self._secret.set(secretInput)
            } catch {
                // process error
            }
        }

        // Remove value
         Button("Remove") {
            do {
                try self._secret.remove()
            } catch {
                // process error
            }
        }
    }
}
```

### Configure Keychain
Besides the default keychain `@AppKeychainStorage` also supports any developer-defined Keychain.

```swift
struct YourView: View {
    @AppKeychainStorage(.secret, keychain: .accessGroupKeychain) var secret

    var body: some View {
        ...
    }
}

extension Keychain {
    // Keychain with custom access group to share Keychain item with extenstions
    static let accessGroupKeychain = Keychain(accessGroup: "NS8HLGG733.com.swifty.keychain.example")
}
```

 ### Configure default Keychain
 Using `defaultAppKeychainStorage` modifier allows setting a default Keychain for the view or scene, avoiding the need to set it repeatedly in each `@AppKeychainStorage`

 ```swift
 @main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            YourView()
                .defaultAppKeychainStorage(.accessGroupKeychain)
        }
        .defaultAppKeychainStorage(.accessGroupKeychain)
    }
}
 ```

## Supported types
- Int
- String
- Double
- Float
- Bool
- Data

### Codable
```swift
struct MyStruct: Codable, KeychainSerializable { ... }
```

### NSCoding
```swift
class MyClass: NSObject, NSCoding, KeychainSerializable { ... }
```

### Custom types
In order to save/get your own custom type that we don't support, you need to confirm it `KeychainSerializable` and implement `KeychainBridge` for this type.

As an example saving `Array<String>` using `JSONSerialization`:

```swift 
extension Array: KeychainSerializable where Element == String  {
    public static var bridge: KeychainBridge<[String]> { return KeychainBridgeStringArray() }
}
```

```swift
class KeychainBridgeStringArray: KeychainBridge<[String]> {
    public override func set(_ value: [String], forKey key: String, in keychain: Keychain) throws {
        guard let data = try? JSONSerialization.data(withJSONObject: value, options: []) else {
            fatalError()
        }
        try? persist(value: data, key: key, keychain: keychain)
    }

    public override func get(key: String, from keychain: Keychain) throws -> [String]? {
        guard let data = try? find(key: key, keychain: keychain) else {
            return nil
        }

        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String]
    }
}
```

## Supported attributes
**Common**
- [x] kSecAttrAccessGroup 
- [x] kSecAttrAccessible 
- [x] kSecAttrDescription
- [x] kSecAttrComment
- [x] kSecAttrCreator
- [x] kSecAttrType
- [x] kSecAttrLabel
- [x] kSecAttrIsInvisible
- [x] kSecAttrIsNegative
- [x] kSecAttrAccount
- [x] kSecAttrSynchronizable

**Generic password**
- [ ] kSecAttrAccessControl
- [x] kSecAttrService 
- [x] kSecAttrGeneric

**Internet password**
- [x] kSecAttrSecurityDomain
- [x] kSecAttrServer
- [x] kSecAttrProtocol
- [x] kSecAttrAuthenticationType
- [x] kSecAttrPort
- [x] kSecAttrPath


## Requirement

**Swift** version **5.0**

Platform     | Availability
------------ | -------------
iOS          | >= 12.0
macOS        | -
tvOS         | - 
watchOS      | -

## Installation
```swift
let package = Package(
    dependencies: [
        .Package(url: "https://github.com/andriyslyusar/SwiftyKeychainKit.git", .exact("1.0.0-beta.2"))
    ]
)
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