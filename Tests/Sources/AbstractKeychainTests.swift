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
    let genericPasswordKey1: KeychainKey<T> = .genericPassword(key: "key1", service: "com.swifty.keychainkit")
    let genericPasswordKey2: KeychainKey<T> = .genericPassword(key: "key2", service: "com.swifty.keychainkit")
    let internetPasswordKey1: KeychainKey<T> = .internetPassword(
        key: "key3",
        url: URL(string: "https://github.com")!,
        scheme: .https,
        authenticationType: .httpBasic
    )

    var value1: T.T!
    var value2: T.T!
    var value3: T.T!

    override func setUp() {
        super.setUp()

        do { try Keychain().removeAll() } catch {}
        do { try Keychain(accessGroup: "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost").removeAll() } catch {}
    }

    // MARK: Generic Password

    func testGenericPassword() {
        let keychain = Keychain()

        // Add Keychain items
        do {
            XCTAssertNoThrow(try keychain.set(value1, for: genericPasswordKey1))
            XCTAssertNoThrow(try keychain.set(value2, for: genericPasswordKey2))

            XCTAssertEqual(try! keychain.get(genericPasswordKey1), value1)
            XCTAssertEqual(try! keychain.get(genericPasswordKey2), value2)
        }

        // Update Keychain items
        do {
            XCTAssertNoThrow(try keychain.set(value2, for: genericPasswordKey1))
            XCTAssertNoThrow(try keychain.set(value1, for: genericPasswordKey2))

            XCTAssertEqual(try! keychain.get(genericPasswordKey1), value2)
            XCTAssertEqual(try! keychain.get(genericPasswordKey2), value1)
        }

        // Remove Keychain items
        do {
            XCTAssertNoThrow(try keychain.remove(genericPasswordKey1))
            XCTAssertNoThrow(try keychain.remove(genericPasswordKey2))

            XCTAssertNil(try! keychain.get(genericPasswordKey1))
            XCTAssertNil(try! keychain.get(genericPasswordKey2))
        }
    }

    func testGenericPasswordSubscripting() {
        let keychain = Keychain()

        // Add Keychain items
        do {
            XCTAssertNoThrow(try keychain.set(value1, for: genericPasswordKey1))
            XCTAssertNoThrow(try keychain.set(value2, for: genericPasswordKey2))

            XCTAssertEqual(try! keychain[genericPasswordKey1].get(), value1)
            XCTAssertEqual(try! keychain[genericPasswordKey2].get(), value2)
        }

        // Update Keychain items
        do {
            XCTAssertNoThrow(try keychain.set(value2, for: genericPasswordKey1))
            XCTAssertNoThrow(try keychain.set(value1, for: genericPasswordKey2))

            XCTAssertEqual(try! keychain[genericPasswordKey1].get(), value2)
            XCTAssertEqual(try! keychain[genericPasswordKey2].get(), value1)
        }

        // Remove Keychain items
        do {
            XCTAssertNoThrow(try keychain.remove(genericPasswordKey1))
            XCTAssertNoThrow(try keychain.remove(genericPasswordKey2))

            XCTAssertNil(try! keychain[genericPasswordKey1].get())
            XCTAssertNil(try! keychain[genericPasswordKey2].get())
        }
    }

    func testGenericPasswordDynamicCallable() {
        let keychain = Keychain()

        // Add Keychain items
        do {
            XCTAssertNoThrow(try keychain.set(value1, for: genericPasswordKey1))
            XCTAssertNoThrow(try keychain.set(value2, for: genericPasswordKey2))

            XCTAssertEqual(try! keychain(genericPasswordKey1).get(), value1)
            XCTAssertEqual(try! keychain(genericPasswordKey2).get(), value2)
        }

        // Update Keychain items
        do {
            XCTAssertNoThrow(try keychain.set(value2, for: genericPasswordKey1))
            XCTAssertNoThrow(try keychain.set(value1, for: genericPasswordKey2))

            XCTAssertEqual(try! keychain(genericPasswordKey1).get(), value2)
            XCTAssertEqual(try! keychain(genericPasswordKey2).get(), value1)
        }

        // Remove Keychain items
        do {
            XCTAssertNoThrow(try keychain.remove(genericPasswordKey1))
            XCTAssertNoThrow(try keychain.remove(genericPasswordKey2))

            XCTAssertNil(try! keychain(genericPasswordKey1).get())
            XCTAssertNil(try! keychain(genericPasswordKey2).get())
        }
    }

    func testKeychainGetWithDefaultValue() {
        let keychain = Keychain()

        XCTAssertEqual(try! keychain.get(genericPasswordKey1, default: value3), value3)
        XCTAssertEqual(try! keychain.get(genericPasswordKey2, default: value3), value3)
    }

    func testKeychainGetSubsriptWithDefaultValue() {
        let keychain = Keychain()

        XCTAssertEqual(try! keychain[genericPasswordKey1, default: value3].get(), value3)
        XCTAssertEqual(try! keychain[genericPasswordKey2, default: value3].get(), value3)
    }

    // MARK: Internet Password
//
//    func testInternetPassword() {
//        // Add Keychain items
//        do {
//            let keychain = Keychain(server: URL(string: "https://github.com")!, protocolType: .https)
//
//            XCTAssertNoThrow(try keychain.set(value1, for: key1))
//            XCTAssertNoThrow(try keychain.set(value2, for: key2))
//
//            XCTAssertEqual(try! keychain.get(key1), value1)
//            XCTAssertEqual(try! keychain.get(key2), value2)
//        }
//
//        // Update Keychain items
//        do {
//            let keychain = Keychain(server: URL(string: "https://github.com")!, protocolType: .https)
//
//            XCTAssertNoThrow(try keychain.set(value2, for: key1))
//            XCTAssertNoThrow(try keychain.set(value1, for: key2))
//
//            XCTAssertEqual(try! keychain.get(key1), value2)
//            XCTAssertEqual(try! keychain.get(key2), value1)
//        }
//
//        // Remove Keychain items
//        do {
//            let keychain = Keychain(server: URL(string: "https://github.com")!, protocolType: .https)
//
//            XCTAssertNoThrow(try keychain.remove(key1))
//            XCTAssertNoThrow(try keychain.remove(key2))
//
//            XCTAssertNil(try! keychain.get(key1))
//            XCTAssertNil(try! keychain.get(key2))
//        }
//    }
//
//    // MARK: Remove all
//
    func testKeychainRemoveAll() throws {
        let keychain = Keychain()

        // Add values to keychain
        try keychain.set(value2, for: genericPasswordKey1)
        try keychain.set(value1, for: internetPasswordKey1)

        // Remove all values
        try keychain.removeAll()

        // Check values
        XCTAssertNil(try keychain.get(genericPasswordKey1))
        XCTAssertNil(try keychain.get(internetPasswordKey1))
    }

    func testKeychainRemoveAllOfTypeGenericPassword() throws {
        let keychain = Keychain()

        // Add values to keychain
        try keychain.set(value2, for: genericPasswordKey1)
        try keychain.set(value1, for: internetPasswordKey1)

        // Remove all values of type GenericPassword
        try keychain.removeAll(ofType: .genericPassword)

        // Check values
        XCTAssertNil(try keychain.get(genericPasswordKey1))
        XCTAssertNotNil(try keychain.get(internetPasswordKey1))
    }

    func testKeychainRemoveAllOfTypeInternetPassword() throws {
        let keychain = Keychain()

        // Add values to keychain of type InternetPassword
        try keychain.set(value2, for: genericPasswordKey1)
        try keychain.set(value1, for: internetPasswordKey1)

        // Remove all values
        try keychain.removeAll(ofType: .internetPassword)

        // Check values
        XCTAssertNotNil(try keychain.get(genericPasswordKey1))
        XCTAssertNil(try keychain.get(internetPasswordKey1))
    }
}
