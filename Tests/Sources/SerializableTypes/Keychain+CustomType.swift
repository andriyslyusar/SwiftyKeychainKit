//
// Keychain+CustomType.swift
//
// Created by Andriy Slyusar on 2019-10-08.
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
import Quick
@testable import SwiftyKeychainKit

class KeychainCustomTypeSpec: QuickSpec, SerializableSpec {
    typealias Serializable = [String]

    var value: [String] = ["1", "2"]
    var updateValue: [String] = ["1", "2", "3"]
    var defaultValue: [String] = ["1", "2", "3", "4"]

    override func spec() {
        describe("Data value") {
            self.testGenericPassword()
            self.testInternetPassword()
        }
    }
}

extension Array: KeychainSerializable where Element == String  {
    public static var bridge: KeychainBridge<[String]> { return KeychainBridgeStringArray() }
}

class KeychainBridgeStringArray: KeychainBridge<[String]> {
    public override func set(_ value: [String], forKey key: String, with attributes: KeychainKeys.Attributes, in keychain: Keychain) throws {
        guard let data = try? JSONSerialization.data(withJSONObject: value, options: []) else {
            fatalError()
        }
        try? persist(value: data, key: key, attributes: attributes, keychain: keychain)
    }

    public override func get(key: String, from keychain: Keychain) throws -> [String]? {
        guard let data = try? find(key: key, keychain: keychain) else {
            return nil
        }

        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String]
    }
}
