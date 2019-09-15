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

private let keychainService = "com.swifty.keychain.example"

class KeychainBridgeIntTests: XCTestCase {
    override func setUp() {
        super.setUp()
        do { try Keychain(service: keychainService).removeAll() } catch {}
    }

    func test_saveAndGetString_suceessfully() {
        let keychain = Keychain(service: keychainService)
        let keychainBridge = KeychainBridgeString()

        /// Save value
        XCTAssertNoThrow(try keychainBridge.save(key: "key", value: "value1", keychain: keychain))
        XCTAssertEqual(try keychainBridge.get(key: "key", keychain: keychain), "value1")

        /// Update value
        XCTAssertNoThrow(try keychainBridge.save(key: "key", value: "value2", keychain: keychain))
        XCTAssertEqual(try keychainBridge.get(key: "key", keychain: keychain), "value2")
    }
}

class KeychainBridgeStringTests: XCTestCase {
    override func setUp() {
        super.setUp()
        do { try Keychain(service: keychainService).removeAll() } catch {}
    }

    func test_saveAndGet_successfully() {
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

class KeychainBridgeCodableTests: XCTestCase {
    override func setUp() {
        super.setUp()
        do { try Keychain(service: keychainService).removeAll() } catch {}
    }

    func test_saveAndGetCodable_successfully() {
        let keychain = Keychain(service: keychainService)
        let keychainBridge = KeychainBridgeCodable<CodableMock>()

        do {
            let codable = CodableMock(intProperty: 10)
            /// Save value
            XCTAssertNoThrow(try keychainBridge.save(key: "key", value: codable, keychain: keychain))
            XCTAssertEqual(try keychainBridge.get(key: "key", keychain: keychain), codable)
        }

        do {
            let codable = CodableMock(intProperty: 20)
            /// Save value
            XCTAssertNoThrow(try keychainBridge.save(key: "key", value: codable, keychain: keychain))
            XCTAssertEqual(try keychainBridge.get(key: "key", keychain: keychain), codable)
        }
    }

    func test_getCodable_itemDooesNotExist() {
        let keychain = Keychain(service: keychainService)
        let keychainBridge = KeychainBridgeCodable<CodableMock>()

        XCTAssertNil(try keychainBridge.get(key: "key", keychain: keychain))
    }

    func test_getCodable_itemFailedToDecode() throws {
        let keychain = Keychain(service: keychainService)
        let keychainBridge = KeychainBridgeCodable<CodableMock>()
        let keychainBridge2 = KeychainBridgeCodable<CodableMockTwo>()

        try keychainBridge.save(key: "key", value: CodableMock(intProperty: 10), keychain: keychain)

        XCTAssertThrowsError(try keychainBridge2.get(key: "key", keychain: keychain))
    }

    private struct CodableMock: Codable, Equatable {
        let intProperty: Int
    }

    private struct CodableMockTwo: Codable, Equatable {
        let stringProperty: String
    }
}
