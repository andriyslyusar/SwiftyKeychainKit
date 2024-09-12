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

@dynamicCallable
public struct Keychain: Sendable {
    /// Keychain items with share access  group
    public var accessGroup: String?

    /// Initializes a new instance of Keychain.
    /// - Parameter accessGroup: An optional access group for shared access.
    ///
    /// ```
    /// let keychain = Keychain()
    /// let keychainWithGroup = Keychain(accessGroup: "group.com.example")
    /// ```
    public init(accessGroup: String? = nil) {
        self.accessGroup = accessGroup
    }

    /// Stores a value in the keychain for a specified key.
    /// - Parameter value: The value to be stored.
    /// - Parameter key: The key associated with the value.
    /// - Throws: A KeychainError if the operation fails.
    ///
    /// ```
    /// try keychain.set("mySecret", for: .mySecretKey)
    /// ```
    public func set<T: KeychainSerializable>(_ value: T, for key: Keychain.Key<T>) throws {
        try set(value, forKey: key)
    }

    /// Retrieves a value from the keychain for a specified key.
    /// - Parameter key: The key associated with the value.
    /// - Throws: A KeychainError if the operation fails.
    /// - Returns: The value associated with the key
    ///
    /// ```
    /// let value = try keychain.get(.mySecretKey)
    /// ```
    public func get<T: KeychainSerializable>(_ key: Keychain.Key<T>) throws -> T? {
        try get(key: key)
    }

    /// Remove key with value from the  keychain
    /// - Parameter key: The key associated with the value to be removed.
    /// - Throws: A KeychainError if the operation fails.
    ///
    /// ```
    /// try keychain.remove(.mySecretKey)
    /// ```
    public func remove<T: KeychainSerializable>(_ key: Keychain.Key<T>) throws {
        try remove(key: key)
    }

    /// Removes all keys and values from the keychain.
    /// - Throws: A KeychainError if the operation fails.
    ///
    /// ```
    /// try keychain.removeAll()
    /// ```
    public func removeAll() throws {
        try removeAll(ofType: .genericPassword)
        try removeAll(ofType: .internetPassword)
    }

    /// Removes all keys and values of a specific type from the keychain.
    /// - Parameter type: The type of items to remove.
    /// - Throws: A KeychainError if the operation fails.
    ///
    /// ```
    /// try keychain.removeAll(ofType: .internetPassword)
    /// ```
    public func removeAll(ofType type: ItemClass) throws {
        var searchRequestAttributes = [any Attribute]()
        searchRequestAttributes += self.searchRequestAttributes
        searchRequestAttributes.append(KeychainAttribute.class(type))
        searchRequestAttributes.append(SynchronizableAnyAttribute())

        let status = keychainItemDelete(searchRequestAttributes)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError(status: status)
        }
    }

    /// Retrieves the result of a keychain query using a subscript syntax.
    /// - Parameter key: The key associated with the value.
    /// - Returns: A Result containing the value or a KeychainError.
    ///
    /// ```
    /// let result = keychain[.mySecretKey]
    /// switch result {
    /// case .success(let value):
    ///     print("Retrieved value: \(value)")
    /// case .failure(let error):
    ///     print("Error: \(error)")
    /// }
    /// ```
    public subscript<T: KeychainSerializable>(key: Keychain.Key<T>) -> Result<T?, KeychainError> {
        do {
            return .success(try get(key))
        } catch {
            return .failure(KeychainError(error))
        }
    }

    /// Dynamically retrieves a value from the keychain using dynamic callable syntax.
    /// - Parameter args: A single Keychain.Key object.
    /// - Throws: A KeychainError if the operation fails.
    /// - Returns: The value associated with the key
    ///
    /// ```
    /// let value = try keychain(.mySecretKey)
    /// ```
    public func dynamicallyCall<T: KeychainSerializable>(withArguments args: [Keychain.Key<T>]) throws -> T? {
        return try get(args[0])
    }


    /// Dynamically retrieves a value from the keychain using dynamic callable syntax.
    /// - Parameter args: A single Keychain.Key object.
    /// - Returns: A Result containing the value or a KeychainError.
    /// - Note: Cast return type to Result to handle ambiguous use of method.
    ///
    /// ```
    /// let result: Result<String?, KeychainError> = keychain(.mySecretKey)
    /// switch result {
    /// case .success(let value):
    ///     print("Retrieved value: \(value)")
    /// case .failure(let error):
    ///     print("Error: \(error)")
    /// }
    ///
    /// if case .success(let value) = keychain(.mySecretKey) as Result { ... }
    /// ```
    public func dynamicallyCall<T: KeychainSerializable>(withArguments args: [Keychain.Key<T>]) -> Result<T?, KeychainError> {
        do {
            return .success(try get(args[0]))
        } catch {
            return .failure(KeychainError(error))
        }
    }

    /// Retrieves attributes for a specified key from the keychain.
    /// - Parameter key: The key associated with the value.
    /// - Throws: A KeychainError if the operation fails.
    /// - Returns: An array of KeychainAttributes associated with the key.
    ///
    /// ```
    /// let attributes = try keychain.attributes(.mySecretKey)
    /// ```
    public func attributes<T: KeychainSerializable>(_ key: Keychain.Key<T>) throws -> [KeychainAttribute] {
        try attributes(key: key)
    }

    /// Checks if a key is stored in the Keychain.
    /// - Parameter key: The key to check.
    /// - Throws: A KeychainError if the operation fails.
    /// - Returns: True if the key exists, false otherwise.
    ///
    /// ```
    /// let isStored = try keychain.hasKey(.mySecretKey)
    /// ```
    public func hasKey<T>(_ key: Keychain.Key<T>) throws -> Bool {
        let attributesToSearch: [any Attribute] = self.searchRequestAttributes
            + key.searchRequestAttributes
            + [KeychainAttribute.account(key.key)]
            + [SearchResultAttribute.matchLimit(.one)]
            + [ReturnResultAttribute.returnData(false)]

        let status = SecItemCopyMatching(attributesToSearch.compose(), nil)
        switch status {
            case errSecSuccess:
               return true
            case errSecItemNotFound:
                return false
            default:
                throw KeychainError(status: status)
        }
    }

    /// Retrieve the keys of all stored items
    /// - Throws: A KeychainError if the operation fails.
    /// - Returns: An array of KeychainItem representing the stored items.
    ///
    /// ```swift
    /// let items = try keychain.items()
    /// ```
    public func items() throws -> [any KeychainItem] {
        [try items(ofType: .genericPassword), try items(ofType: .internetPassword)]
            .flatMap { $0 }
    }

    /// Retrieves the keys of all stored items of a specific type.
    /// - Parameter type: The type of items to retrieve.
    /// - Throws: A KeychainError if the operation fails.
    /// - Returns: An array of KeychainItem representing the stored items.
    ///
    /// ```swift
    /// let items = try keychain.items(ofType: .internetPassword)
    /// ```
    public func items(ofType type: ItemClass) throws -> [any KeychainItem] {
        let request: [any Attribute] = self.searchRequestAttributes
        + [
            KeychainAttribute.class(type),
            SearchResultAttribute.matchLimit(.all),
            ReturnResultAttribute.returnAttributes(true),
            ReturnResultAttribute.returnData(false),
            ReturnResultAttribute.returnRef(true)
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(request.compose(), &result)
        switch status {
            case errSecSuccess:
                guard let items = result as? [[String: Any]] else {
                    throw KeychainError.unexpectedError
                }

                return items.compactMap { item in
                    guard let key = item[kSecAttrAccount as String] as? String else { return nil }
                    let keychainAttributes = item.compactMap { KeychainAttribute(key: $0, value: $1) }

                    switch keychainAttributes.class {
                        case .genericPassword:
                            return GenericPassword(key: key, attributes: keychainAttributes)
                        case .internetPassword:
                            return InternetPassword(key: key, attributes: keychainAttributes)
                        case .none:
                            return nil
                    }
                }

            case errSecItemNotFound:
                return []

            default:
                throw KeychainError(status: status)
        }
    }
}

public extension Keychain {
    /// The default instance of Keychain.
    ///
    /// ```
    /// let defaultKeychain = Keychain.default
    /// ```
    static let `default` = Keychain()
}

private extension Keychain {
    func set<T: KeychainSerializable>(_ value: T, forKey key: Keychain.Key<T>) throws {
        let attributesToSearch: [any Attribute] = self.searchRequestAttributes
            + key.searchRequestAttributes
            + [KeychainAttribute.account(key.key)]

        let status = keychainItemFetch(attributesToSearch)
        switch status {
            // Keychain already contains key -> update existing item
            case errSecSuccess:
                let attributesToUpdate = key.updateRequestAttributes
                    + [KeychainAttribute.valueData(try value.encode())]

                let status = keychainItemUpdate(
                    attributesToSearch: attributesToSearch,
                    attributesToUpdate: attributesToUpdate
                )
                if status != errSecSuccess {
                    throw KeychainError(status: status)
                }

            // Keychain doesn't contain key -> add new item
            case errSecItemNotFound:
                let attributesToAdd = self.searchRequestAttributes
                    + key.searchRequestAttributes
                    + key.updateRequestAttributes
                    + [KeychainAttribute.account(key.key), KeychainAttribute.valueData(try value.encode())]

                let status = keychainItemAdd(attributesToAdd)
                if status != errSecSuccess {
                    throw KeychainError(status: status)
                }

            // This error can happen when your app is launched in the background while the device is locked
            // (for example, in response to an actionable push notification or a Core Location geofence event),
            // the application may crash as a result of accessing a locked keychain entry.
            //
            // TODO: Maybe introduce `force` property to allow remove and save key with different permissions
            case errSecInteractionNotAllowed:
                throw KeychainError(status: status)

            default:
                throw KeychainError(status: status)
        }
    }

    func get<T: KeychainSerializable>(key: Keychain.Key<T>) throws -> T? {
        let attributesToSearch: [any Attribute] = self.searchRequestAttributes
            + key.searchRequestAttributes
            + [KeychainAttribute.account(key.key)]
            + [SearchResultAttribute.matchLimit(.one)]
            + [ReturnResultAttribute.returnData(true)]

        var result: AnyObject?
        let status = SecItemCopyMatching(attributesToSearch.compose(), &result)
        switch status {
            case errSecSuccess:
                guard let data = result as? Data else {
                    throw KeychainError.unexpectedError
                }
                return try T.decode(data)

            case errSecItemNotFound:
                return nil

            default:
                throw KeychainError(status: status)
        }
    }

    func attributes<T: KeychainSerializable>(key: Keychain.Key<T>) throws -> [KeychainAttribute] {
        let attributesToSearch: [any Attribute] = self.searchRequestAttributes
            + key.searchRequestAttributes
            + [KeychainAttribute.account(key.key)]
            + [SearchResultAttribute.matchLimit(.one)]
            + [
                ReturnResultAttribute.returnAttributes(true),
                ReturnResultAttribute.returnRef(true),
                ReturnResultAttribute.returnPersistentRef(true),
            ]

        var result: AnyObject?
        let status = SecItemCopyMatching(attributesToSearch.compose(), &result)
        switch status {
            case errSecSuccess:
                guard let data = result as? [String: Any] else {
                    throw KeychainError.unexpectedError
                }
                return data.compactMap { KeychainAttribute(key: $0, value: $1) }

            default:
                throw KeychainError(status: status)
        }
    }

    func remove<T: KeychainSerializable>(key: Keychain.Key<T>) throws {
        let attributesToSearch: [any Attribute] = self.searchRequestAttributes
            + key.searchRequestAttributes
            + [KeychainAttribute.account(key.key)]

        let status = keychainItemDelete(attributesToSearch)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError(status: status)
        }
    }

    func keychainItemDelete(_ attributes: [any Attribute]) -> OSStatus {
        return SecItemDelete(attributes.compose())
    }

    func keychainItemAdd(_ attributes: [any Attribute]) -> OSStatus {
        return SecItemAdd(attributes.compose(), nil)
    }

    /// Modifies items that match a search query.
    /// Keychain SecItemUpdate do not allow search query parameters and account to pass as `attributesToUpdate`
    /// - Parameters:
    ///   - query: Attributes collection that describes the search for the keychain items you want to update.
    ///   - attributes: Attributes collection containing the attributes whose values should be changed, along with the new values.
    /// - Returns: A result code
    func keychainItemUpdate(attributesToSearch: [any Attribute], attributesToUpdate: [any Attribute]) -> OSStatus {
        return SecItemUpdate(attributesToSearch.compose(), attributesToUpdate.compose())
    }

    func keychainItemFetch(_ attributes: [any Attribute]) -> OSStatus {
        return SecItemCopyMatching(attributes.compose(), nil)
    }

    /// Build keychain search request attributes
    var searchRequestAttributes: [any Attribute] {
        var attributes = [any Attribute]()
        accessGroup.flatMap { attributes.append(KeychainAttribute.accessGroup($0)) }
        return attributes
    }
}

private extension Keychain.Key {
    var searchRequestAttributes: [any Attribute] {
        var attributes = [any Attribute]()
        attributes.append(SynchronizableAnyAttribute())

        switch self {
            case .genericPassword(let attr):
                attributes.append(KeychainAttribute.class(.genericPassword))
                attributes.append(KeychainAttribute.service(attr.service))

            case .internetPassword(let attr):
                attributes.append(KeychainAttribute.class(.internetPassword))

                attributes.append(KeychainAttribute.protocolType(attr.protocolType))
                attributes.append(KeychainAttribute.server(attr.domain))
                attr.path.flatMap { attributes.append(KeychainAttribute.path($0)) }
                attr.port.flatMap { attributes.append(KeychainAttribute.port($0)) }

                // TODO: Investigate do we really require AuthenticationType on internet password
                attributes.append(KeychainAttribute.authenticationType(attr.authenticationType))

                attr.securityDomain.flatMap { attributes.append(KeychainAttribute.securityDomain($0)) }
        }

        return attributes
    }

    var updateRequestAttributes: [any Attribute] {
        var attributes = [KeychainAttribute]()

        attributes.append(.accessible(accessible))
        attributes.append(.synchronizable(synchronizable))

        label.flatMap { attributes.append(.label($0)) }
        comment.flatMap { attributes.append(.comment($0)) }
        desc.flatMap { attributes.append(.attrDescription($0)) }
        isInvisible.flatMap { attributes.append(.isInvisible($0)) }
        isNegative.flatMap { attributes.append(.isNegative($0)) }
        creator.flatMap { attributes.append(.creator($0)) }
        type.flatMap { attributes.append(.type($0)) }

        if case let .genericPassword(attrs) = self, let generic = attrs.generic {
            attributes.append(.generic(generic))
        }

        return attributes
    }
}
