//
// KeychainTests.CustomType.swift
//
// Created by Andriy Slyusar on 2022-10-27.
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
@testable import SwiftyKeychainKit

class KeychainCustomTypeTests: AbstractKeychainTests<[String]> {
    override var value1: [String]! {
        get { ["1", "2"] }
        set {}
    }

    override var value2: [String]! {
        get { ["1", "2", "3"] }
        set {}
    }

    override var value3: [String]! {
        get {  ["1", "2", "3", "4"] }
        set {}
    }
}

extension [String]: KeychainSerializable  {
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
