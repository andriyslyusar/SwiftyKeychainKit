//
// KeychainBridgeTests.swift
//
// Created by Andriy Slyusar on 2019-09-09.
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

import XCTest
@testable import SwiftyKeychain

class KeychainBridgeTests: XCTestCase {
    private let keychainService = "com.swifty.keychain.example"

    override func setUp() {
        super.setUp()

        do { try Keychain(service: keychainService).removeAll() } catch {}
    }

    func testSaveAndGetString() {
        let keychain = Keychain(service: keychainService)
        let keychainBridge = KeychainBridgeString()

        /// Save value
        XCTAssertNoThrow(try keychainBridge.save(key: "key", value: "value1", keychain: keychain))
        XCTAssertEqual(try keychainBridge.get(key: "key", keychain: keychain), "value1")

        /// Update value
        XCTAssertNoThrow(try keychainBridge.save(key: "key", value: "value2", keychain: keychain))
        XCTAssertEqual(try keychainBridge.get(key: "key", keychain: keychain), "value2")
    }


    func testSaveAndGetInt() {
        let keychain = Keychain(service: keychainService)
        let keychainBridge = KeychainBridgeInt()

        /// Save value
        XCTAssertNoThrow(try keychainBridge.save(key: "key", value: 10, keychain: keychain))
        XCTAssertEqual(try keychainBridge.get(key: "key", keychain: keychain), 10)

        /// Update value
        XCTAssertNoThrow(try keychainBridge.save(key: "key", value: 20, keychain: keychain))
        XCTAssertEqual(try keychainBridge.get(key: "key", keychain: keychain), 20)
    }
}
