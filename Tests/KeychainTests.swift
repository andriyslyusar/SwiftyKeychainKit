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
@testable import SwiftyKeychainKit


extension KeychainKeys {
    static let stringKey = KeychainKey<String>(key: "Key")
}

class KeychainTests: XCTestCase {
    private let keychainService = "com.swifty.keychain.example"
    private let keychainAccessGroup = "W7JL9XM57U.com.swifty.keychain.tests.host.TestsHost"

    override func setUp() {
        super.setUp()

        do { try Keychain(service: keychainService).removeAll() } catch {}
        do { try Keychain(service: keychainService, accessGroup: keychainAccessGroup).removeAll() } catch {}
    }

    func testInitializer() {
        do {
            let keychain = Keychain(service: keychainService)
            XCTAssertEqual(keychain.service, keychainService)
            XCTAssertEqual(keychain.accessible, AccessibilityLevel.whenUnlocked)
            XCTAssertEqual(keychain.itemClass, ItemClass.genericPassword)
        }

        do {
            let keychain = Keychain(service: keychainService, accessible: .whenPasscodeSetThisDeviceOnly)
            XCTAssertEqual(keychain.service, keychainService)
            XCTAssertEqual(keychain.accessible, AccessibilityLevel.whenPasscodeSetThisDeviceOnly)
            XCTAssertEqual(keychain.itemClass, ItemClass.genericPassword)
        }

        do {
            let keychain = Keychain(service: keychainService,
                                    accessible: .whenPasscodeSetThisDeviceOnly,
                                    accessGroup: keychainAccessGroup)
            XCTAssertEqual(keychain.service, keychainService)
            XCTAssertEqual(keychain.accessible, AccessibilityLevel.whenPasscodeSetThisDeviceOnly)
            XCTAssertEqual(keychain.itemClass, ItemClass.genericPassword)
            XCTAssertEqual(keychain.accessGroup, keychainAccessGroup)
        }
    }

    func testSaveAndGetStringKeychain() {
        let keychain = Keychain(service: keychainService)
        let key = KeychainKey<String>(key: "Key")

        /// Save new value
        XCTAssertNoThrow(try keychain.save("secret", key: key))
        XCTAssertEqual(try keychain.get(key), "secret")
        XCTAssertEqual(try keychain.get(.stringKey), "secret")
        XCTAssertEqual(try keychain[.stringKey].get(), "secret")


        if case .success(let value) = keychain[.stringKey] {
            XCTAssertEqual(value, "secret")
        }


//        let a = keychain[.stringKey]

        let key2 = KeychainKey<String>(key: "Key2")

        XCTAssertEqual(try keychain[key2, default: "secret2"].get(), "secret2")
        XCTAssertEqual(try keychain.get(key2, default: "secret3"), "secret3")

//        XCTAssertEqual(keychain[key: key], "secret")
//
//        let a = try? keychain[key].get()


        
//        let a = keychain[key, { error in }]

//        keychain[key, () -> ({ print($0)})] = ""

//        keychain[key, { error in }] = "some value"

//        XCTAssertEqual(keychain[.stringKey], "secret")

//        XCTAssertEqual(try keychain[key](), "secret")

//        let a = keychain[key]
//        switch a {
//        case .success(let value):
//            ()
//        case .failure(let error):
//            ()
//        }

        /// Update value
        XCTAssertNoThrow(try keychain.save("secret2", key: key))
        XCTAssertEqual(try keychain.get(key), "secret2")
        XCTAssertEqual(try keychain[key].get(), "secret2")
    }

//    func test_saveAndGetStringKeychainWithAccessGroup() {
//        let keychain = Keychain(service: keychainService, accessGroup: keychainAccessGroup)
//        let key = KeychainKey<String>(key: "Key")
//
//        /// Save new value
//        XCTAssertNoThrow(try keychain.save("secret", key: key))
//        XCTAssertEqual(try keychain.get(key: key), "secret")
//
//        /// Update value
//        XCTAssertNoThrow(try keychain.save("secret2", key: key))
//        XCTAssertEqual(try keychain.get(key: key), "secret2")
//    }

    func testSaveAndGetIntKeychain() {
        let keychain = Keychain(service: keychainService)
        let key = KeychainKey<Int>(key: "Key")

        /// Save new value
        XCTAssertNoThrow(try keychain.save(10, key: key))
        XCTAssertEqual(try keychain.get(key), 10)

        /// Update value
        XCTAssertNoThrow(try keychain.save(20, key: key))
        XCTAssertEqual(try keychain.get(key), 20)
    }

    func testRemoveSingleGenericPassword() {
        let keychain = Keychain(service: keychainService)

        let key1 = KeychainKey<String>(key: "Key1")
        let key2 = KeychainKey<String>(key: "Key2")

        XCTAssertNoThrow(try keychain.save("secret", key: key1))
        XCTAssertNoThrow(try keychain.save("secret", key: key2))

        XCTAssertNoThrow(try keychain.remove(key1))
        XCTAssertNotNil(try keychain.get(key2))
    }

    func testRemoveAllGenericPasswordObjects() {
        let keychain = Keychain(service: keychainService)

        let key1 = KeychainKey<String>(key: "Key1")
        let key2 = KeychainKey<String>(key: "Key2")

        XCTAssertNoThrow(try keychain.save("secret", key: key1))
        XCTAssertNoThrow(try keychain.save("secret", key: key2))

        XCTAssertNoThrow(try keychain.removeAll())

        XCTAssertNil(try keychain.get(key1))
        XCTAssertNil(try keychain.get(key2))
    }

    func test_updateRequestAttributes_returnDefaultAttributes() {
        let keychain = Keychain(service: "",
                                accessible: .whenUnlocked,
                                synchronizable: false)

        let attributes =  keychain.updateRequestAttributes(value: Data())

        XCTAssertTrue(attributes.contains { $0 == Attribute.valueData(Data()) })
        XCTAssertTrue(attributes.contains { $0 == Attribute.accessible(.whenUnlocked) })
        XCTAssertTrue(attributes.contains { $0 == Attribute.synchronizable(.init(boolValue: false)) })
        XCTAssertEqual(attributes.count, 3)
    }

    func test_addRequestAttributes_returnDefaultAttributes() {
        let keychain = Keychain(service: "",
                                accessible: .whenUnlocked,
                                synchronizable: false)

        let attributes = keychain.addRequestAttributes(value: Data(), key: "account")

//        XCTAssertEqual(attributes.count, 4)

        // attributes from updateRequestAttributes
        XCTAssertTrue(attributes.contains { $0 == Attribute.valueData(Data()) })
        XCTAssertTrue(attributes.contains { $0 == Attribute.accessible(.whenUnlocked) })
        XCTAssertTrue(attributes.contains { $0 == Attribute.synchronizable(.init(boolValue: false)) })

        // attributes from addRequestAttributes
        XCTAssertTrue(attributes.contains { $0 == Attribute.account("account") })
    }

}


extension Attribute: Equatable {}

public func ==(lhs: Attribute, rhs: Attribute) -> Bool {
    switch (lhs, rhs) {
    case (.`class`(let a), .`class`(let b)):
        return a == b
    case (.service(let a), .service(let b)):
        return a == b
    case (.account(let a), .account(let b)):
        return a == b
    case (.valueData(let a), .valueData(let b)):
        return a == b
     case (.accessible(let a), .accessible(let b)):
        return a == b
    case (.isReturnData(let a), .isReturnData(let b)):
        return a == b
    case (.matchLimit(let a), .matchLimit(let b)):
        return a == b
    case (.accessGroup(let a), .accessGroup(let b)):
        return a == b
    case (.synchronizable(let a), .synchronizable(let b)):
        return a == b
    case (.server(let a), .server(let b)):
        return a == b
    case (.port(let a), .port(let b)):
        return a == b
    default:
      return false
    }
}
