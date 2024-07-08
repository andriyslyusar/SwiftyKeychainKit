//
// Created by Andriy Slyusar on 2024-07-07.
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

import SwiftUI

@available(iOS 14.0, *)
@propertyWrapper
public struct AppKeychainStorage<T: KeychainSerializable> {
    @StateObject private var tracker = Tracker()

    @Environment(\.defaultAppKeychainStorage) private var defaultKeychain

    private let keychain: Keychain?
    private let key: KeychainKey<T>

    /// Keychain value for key
    /// get - use Result type to persist error while getting key value from keychain.
    /// set - omitted due to Swift does not support 'set' accessor with 'throws'
    public var wrappedValue: Result<T.T?, KeychainError> {
        tracker.value
    }

    public init(_ key: KeychainKey<T>, keychain: Keychain? = nil) {
        self.key = key
        self.keychain = keychain
    }

    /// Persist value for key in keychain
    /// - Parameter newValue: Persisting value
    public func set(_ newValue: T.T?) throws {
        try tracker.set(newValue, key: key, keychain: keychain ?? defaultKeychain)
    }

    public func remove() throws {
        try tracker.remove(key: key, keychain: keychain ?? defaultKeychain)
    }

    private class Tracker: ObservableObject {
        var value: Result<T.T?, KeychainError> = .success(nil)

        func get(key: KeychainKey<T>, keychain: Keychain) {
            self.value = keychain[key]
        }

        func set(_ newValue: T.T?, key: KeychainKey<T>, keychain: Keychain) throws {
            if let newValue {
                try keychain.set(newValue, for: key)
            } else {
                try keychain.remove(key)
            }
            self.value = .success(newValue)

            // Notify state object on changes
            // Avoid the runtime warning in the case of publishers that publish values right on subscription:
            // 'Publishing changes from within view updates is not allowed, this will cause undefined behavior.'
            self.objectWillChange.send()
        }

        func remove(key: KeychainKey<T>, keychain: Keychain) throws {
            try keychain.remove(key)
            self.value = .success(nil)

            // Notify state object on changes
            // Avoid the runtime warning in the case of publishers that publish values right on subscription:
            // 'Publishing changes from within view updates is not allowed, this will cause undefined behavior.'
            self.objectWillChange.send()
        }
    }
}

@available(iOS 14.0, *)
extension AppKeychainStorage: DynamicProperty {
    /// Updates the underlying value of the stored value. SwiftUI calls this function before rendering a view's.
    public func update() {
        tracker.get(key: key, keychain: keychain ?? defaultKeychain)
    }
}

@available(iOS 14.0, *)
public extension View {
    /// The default keychain used by `AppKeychainStorage` contained within the view.
    ///
    /// If unspecified, the default store for a view hierarchy is `Keychain.default`, but can be set a to a custom one.
    /// For example, sharing keychain between an app and an extension can override the default keychain
    /// to one created with `Keychain.init(accessGroup:_)`.
    ///
    /// - Parameter keychain: The keychain to use as the default keychain for `AppKeychainStorage`.
    func defaultAppKeychainStorage(_ keychain: Keychain) -> some View {
        environment(\.defaultAppKeychainStorage, keychain)
    }
}

@available(iOS 14.0, *)
public extension Scene {
    /// The default keychain used by `AppKeychainStorage` contained within the scene its view content.
    ///
    /// If unspecified, the default keychain for a view hierarchy is `Keychain.default`, but can be set a to a custom one.
    /// For example, sharing keychain between an app and an extension can override the keychain store
    /// to one created with `Keychain.init(accessGroup:_)`.
    ///
    /// - Parameter keychain: The keychain to use as the default keychain for `AppKeychainStorage`.
    func defaultAppKeychainStorage(_ keychain: Keychain) -> some Scene {
        environment(\.defaultAppKeychainStorage, keychain)
    }
}

@available(iOS 14.0, *)
public extension EnvironmentValues {
    var defaultAppKeychainStorage: Keychain {
        get { self[AppKeychainStorageKey.self] }
        set { self[AppKeychainStorageKey.self] = newValue }
    }
}

private struct AppKeychainStorageKey: EnvironmentKey {
    static let defaultValue = Keychain.default
}
