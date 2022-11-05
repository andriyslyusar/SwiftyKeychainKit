//
// AbstractKeychainTests.swift
//
// Created by Andriy Slyusar on 2022-10-24.
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
import XCTest
@testable import SwiftyKeychainKit

class AbstractKeychainTests<T: KeychainSerializable>: XCTestCase where T.T: Equatable {
    var key1: KeychainKey<T> = .init(key: "key1")
    var key2: KeychainKey<T> = .init(key: "key2")

    var value1: T.T!
    var value2: T.T!
    var value3: T.T!

//    [7]    (null)    "agrp" : "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost"
    let keychainAccessGroup = "W7JL9XM57U.com.swifty.keychain.tests.host.TestsHost"

    override func setUp() {
        super.setUp()

        do { try Keychain(service: "com.swifty.keychainkit").removeAll() } catch {}
        do { try Keychain(server: URL(string: "https://github.com")!, protocolType: .https).removeAll() } catch {}
    }

    // MARK: Generic Password

    func testGenericPassword() {
        // Add Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.set(value1, for: key1))
            XCTAssertNoThrow(try keychain.set(value2, for: key2))

            XCTAssertEqual(try! keychain.get(key1), value1)
            XCTAssertEqual(try! keychain.get(key2), value2)
        }

        // Update Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.set(value2, for: key1))
            XCTAssertNoThrow(try keychain.set(value1, for: key2))

            XCTAssertEqual(try! keychain.get(key1), value2)
            XCTAssertEqual(try! keychain.get(key2), value1)
        }

        // Remove Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.remove(key1))
            XCTAssertNoThrow(try keychain.remove(key2))

            XCTAssertNil(try! keychain.get(key1))
            XCTAssertNil(try! keychain.get(key2))
        }
    }

    func testGenericPassword1() {
        let aKey1 = KeychainKey<T>(
            key: "key",
            label: "label",
            comment: "comment",
            description: "description",
            isInvisible: true,
            isNegative: false,
            generic: "generic".data(using: .utf8)!
        )

        // Add Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.set(value1, for: aKey1))
            XCTAssertNoThrow(try keychain.set(value2, for: key2))

            XCTAssertEqual(try! keychain.get(aKey1), value1)
            XCTAssertEqual(try! keychain.get(key2), value2)
        }

        // Update Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.set(value2, for: aKey1))
            XCTAssertNoThrow(try keychain.set(value1, for: key2))

            XCTAssertEqual(try! keychain.get(aKey1), value2)
            XCTAssertEqual(try! keychain.get(key2), value1)
        }

        // Remove Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.remove(aKey1))
            XCTAssertNoThrow(try keychain.remove(key2))

            XCTAssertNil(try! keychain.get(aKey1))
            XCTAssertNil(try! keychain.get(key2))
        }
    }

    func testGenericPasswordSubscripting() {
        // Add Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.set(value1, for: key1))
            XCTAssertNoThrow(try keychain.set(value2, for: key2))

            XCTAssertEqual(try! keychain[key1].get(), value1)
            XCTAssertEqual(try! keychain[key2].get(), value2)
        }

        // Update Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.set(value2, for: key1))
            XCTAssertNoThrow(try keychain.set(value1, for: key2))

            XCTAssertEqual(try! keychain[key1].get(), value2)
            XCTAssertEqual(try! keychain[key2].get(), value1)
        }

        // Remove Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.remove(key1))
            XCTAssertNoThrow(try keychain.remove(key2))

            XCTAssertNil(try! keychain[key1].get())
            XCTAssertNil(try! keychain[key2].get())
        }
    }

    func testGenericPasswordDynamicCallable() {
        // Add Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.set(value1, for: key1))
            XCTAssertNoThrow(try keychain.set(value2, for: key2))

            XCTAssertEqual(try! keychain(key1).get(), value1)
            XCTAssertEqual(try! keychain(key2).get(), value2)
        }

        // Update Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.set(value2, for: key1))
            XCTAssertNoThrow(try keychain.set(value1, for: key2))

            XCTAssertEqual(try! keychain(key1).get(), value2)
            XCTAssertEqual(try! keychain(key2).get(), value1)
        }

        // Remove Keychain items
        do {
            let keychain = Keychain(service: "com.swifty.keychainkit")

            XCTAssertNoThrow(try keychain.remove(key1))
            XCTAssertNoThrow(try keychain.remove(key2))

            XCTAssertNil(try! keychain(key1).get())
            XCTAssertNil(try! keychain(key2).get())
        }
    }

    func testKeychainGetWithDefaultValue() {
        let keychain = Keychain(service: "com.swifty.keychainkit")

        XCTAssertEqual(try! keychain.get(key1, default: value3), value3)
        XCTAssertEqual(try! keychain.get(key2, default: value3), value3)
    }

    func testKeychainGetSubsriptWithDefaultValue() {
        let keychain = Keychain(service: "com.swifty.keychainkit")

        XCTAssertEqual(try! keychain[key1, default: value3].get(), value3)
        XCTAssertEqual(try! keychain[key2, default: value3].get(), value3)
    }

    // MARK: Internet Password

    func testInternetPassword() {
        // Add Keychain items
        do {
            let keychain = Keychain(server: URL(string: "https://github.com")!, protocolType: .https)

            XCTAssertNoThrow(try keychain.set(value1, for: key1))
            XCTAssertNoThrow(try keychain.set(value2, for: key2))

            XCTAssertEqual(try! keychain.get(key1), value1)
            XCTAssertEqual(try! keychain.get(key2), value2)
        }

        // Update Keychain items
        do {
            let keychain = Keychain(server: URL(string: "https://github.com")!, protocolType: .https)

            XCTAssertNoThrow(try keychain.set(value2, for: key1))
            XCTAssertNoThrow(try keychain.set(value1, for: key2))

            XCTAssertEqual(try! keychain.get(key1), value2)
            XCTAssertEqual(try! keychain.get(key2), value1)
        }

        // Remove Keychain items
        do {
            let keychain = Keychain(server: URL(string: "https://github.com")!, protocolType: .https)

            XCTAssertNoThrow(try keychain.remove(key1))
            XCTAssertNoThrow(try keychain.remove(key2))

            XCTAssertNil(try! keychain.get(key1))
            XCTAssertNil(try! keychain.get(key2))
        }
    }

    // MARK: Remove all

    func testKeychainRemoveAll() throws {
        let keychain = Keychain(service: "com.swifty.keychainkit")

        // Add values to keychain
        try keychain.set(value2, for: key1)
        try keychain.set(value1, for: key2)

        // Remove all values
        try keychain.removeAll()

        // Check values are nil
        XCTAssertNil(try! keychain.get(key1))
        XCTAssertNil(try! keychain.get(key2))
    }
}
