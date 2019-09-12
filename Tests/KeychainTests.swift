//
// KeychainTests.swift
//
// Created by Andriy Slyusar on 2019-09-07.
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

class KeychainTests: XCTestCase {
    private let keychainService = "com.swifty.keychain.example"

    override func setUp() {
        super.setUp()

        do { try Keychain(service: keychainService).removeAll() } catch {}
    }

    func testInitializer() {
        do {
            let keychain = Keychain(service: keychainService)
            XCTAssertEqual(keychain.service, keychainService)
            XCTAssertEqual(keychain.accessible, AccessibilityLevel.whenUnlocked)
        }

        do {
            let keychain = Keychain(service: keychainService, accessible: .whenPasscodeSetThisDeviceOnly)
            XCTAssertEqual(keychain.service, keychainService)
            XCTAssertEqual(keychain.accessible, AccessibilityLevel.whenPasscodeSetThisDeviceOnly)
        }
    }

    func testSaveAndGetStringKeychain() {
        let keychain = Keychain(service: keychainService)
        let key = KeychainKey<String>(key: "Key")

        /// Save new value
        XCTAssertNoThrow(try keychain.save(key: key, value: "secret"))
        XCTAssertEqual(try keychain.get(key: key), "secret")

        /// Update value
        XCTAssertNoThrow(try keychain.save(key: key, value: "secret2"))
        XCTAssertEqual(try keychain.get(key: key), "secret2")
    }

    func testSaveAndGetIntKeychain() {
        let keychain = Keychain(service: keychainService)
        let key = KeychainKey<Int>(key: "Key")

        /// Save new value
        XCTAssertNoThrow(try keychain.save(key: key, value: 10))
        XCTAssertEqual(try keychain.get(key: key), 10)

        /// Update value
        XCTAssertNoThrow(try keychain.save(key: key, value: 20))
        XCTAssertEqual(try keychain.get(key: key), 20)
    }


    func testRemoveSingleGenericPassword() {
        let keychain = Keychain(service: keychainService)

        let key1 = KeychainKey<String>(key: "Key1")
        let key2 = KeychainKey<String>(key: "Key2")

        XCTAssertNoThrow(try keychain.save(key: key1, value: "secret"))
        XCTAssertNoThrow(try keychain.save(key: key2, value: "secret"))

        XCTAssertNoThrow(try keychain.remove(key: key1))
        XCTAssertNotNil(try keychain.get(key: key2))
    }

    func testRemoveAllGenericPasswordObjects() {
        let keychain = Keychain(service: keychainService)

        let key1 = KeychainKey<String>(key: "Key1")
        let key2 = KeychainKey<String>(key: "Key2")

        XCTAssertNoThrow(try keychain.save(key: key1, value: "secret"))
        XCTAssertNoThrow(try keychain.save(key: key2, value: "secret"))

        XCTAssertNoThrow(try keychain.removeAll())

        XCTAssertNil(try keychain.get(key: key1))
        XCTAssertNil(try keychain.get(key: key2))
    }
}
