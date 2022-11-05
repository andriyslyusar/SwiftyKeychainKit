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

class KeychainTests: XCTestCase {
    // MARK: - Initializers

    func testGenericPasswordDefaultInitializer() {
        let keychain = Keychain(service: "com.swifty.keychainkit")

        XCTAssertEqual(keychain.service, "com.swifty.keychainkit")
        XCTAssertEqual(keychain.itemClass, .genericPassword)
        XCTAssertEqual(keychain.accessible, .whenUnlocked)
        XCTAssertNil(keychain.accessGroup)
        XCTAssertFalse(keychain.synchronizable)
    }

    func testGenericPasswordInitializer() {
        let keychain = Keychain(
            service: "com.swifty.keychainkit",
            accessible: .accessibleAlways,
            accessGroup: "W7JL9XM57U.com.swifty.keychain.tests.host.TestsHost",
            synchronizable: true
        )

        XCTAssertEqual(keychain.service, "com.swifty.keychainkit")
        XCTAssertEqual(keychain.itemClass, .genericPassword)
        XCTAssertEqual(keychain.accessible, .accessibleAlways)
        XCTAssertEqual(keychain.accessGroup, "W7JL9XM57U.com.swifty.keychain.tests.host.TestsHost")
        XCTAssertTrue(keychain.synchronizable)
    }

    func testInternetPasswordDefaultInitializer() {
        let keychain = Keychain(
            server: URL(string: "https://github.com")!,
            protocolType: .https,
            authenticationType: .httpBasic,
            accessible: .afterFirstUnlock,
            accessGroup: "W7JL9XM57U.com.swifty.keychain.tests.host.TestsHost",
            synchronizable: true,
            securityDomain: "securityDomain"
        )

        XCTAssertEqual(keychain.itemClass, .internetPassword)
        XCTAssertEqual(keychain.server, URL(string: "https://github.com")!)
        XCTAssertEqual(keychain.protocolType, .https)
        XCTAssertEqual(keychain.authenticationType, .httpBasic)
        XCTAssertEqual(keychain.accessible, .afterFirstUnlock)
        XCTAssertEqual(keychain.accessGroup, "W7JL9XM57U.com.swifty.keychain.tests.host.TestsHost")
        XCTAssertTrue(keychain.synchronizable)
        XCTAssertEqual(keychain.securityDomain, "securityDomain")
    }

    func testInternetPasswordInitializer() {
        let keychain = Keychain(server: URL(string: "https://github.com")!, protocolType: .https)

        XCTAssertEqual(keychain.itemClass, .internetPassword)
        XCTAssertEqual(keychain.server, URL(string: "https://github.com")!)
        XCTAssertEqual(keychain.protocolType, .https)
        XCTAssertEqual(keychain.authenticationType, .default)
        XCTAssertEqual(keychain.accessible, .whenUnlocked)
        XCTAssertNil(keychain.accessGroup)
        XCTAssertFalse(keychain.synchronizable)
        XCTAssertNil(keychain.securityDomain)
    }

    func testGetGenericPasswordAttributes() throws {
        let keychain = Keychain(
            service: "com.swifty.keychainkit",
            accessible: .accessibleAlways,
//            accessGroup: "W7JL9XM57U.com.swifty.keychain.tests.host.TestsHost",
            synchronizable: false
        )

        let key = KeychainKey<String>(
            key: "key",
            label: "label",
            comment: "comment",
            description: "description",
            isInvisible: true,
            isNegative: false,
            generic: "generic".data(using: .utf8)!
        )

        do {
            try? keychain.set("value", for: key)

            let attributes = try keychain.attributes(key)

            XCTAssertEqual(attributes.class, .genericPassword)
            XCTAssertEqual(attributes.service, "com.swifty.keychainkit")
            XCTAssertEqual(attributes.accessible, .accessibleAlways)
            XCTAssertEqual(attributes.synchronizable, false)
            XCTAssertEqual(attributes.label, "label")
            XCTAssertEqual(attributes.comment, "comment")
            XCTAssertEqual(attributes.attrDescription, "description")
            XCTAssertEqual(attributes.isInvisible, true)
            XCTAssertEqual(attributes.isNegative, false)
            XCTAssertEqual(attributes.generic, "generic".data(using: .utf8)!)
            // TODO: Investigate why accessGroup has a default value
            XCTAssertEqual(attributes.accessGroup, "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost")
        }
    }

    func testGetInternetPasswordAttributes() throws {
        let keychain = Keychain(
            server: URL(string: "https://github.com")!,
            protocolType: .https,
            authenticationType: .httpBasic,
            accessible: .afterFirstUnlock,
//            accessGroup: "W7JL9XM57U.com.swifty.keychain.tests.host.TestsHost",
            synchronizable: true,
            securityDomain: "securityDomain"
        )

        let key = KeychainKey<String>(
            key: "key",
            label: "label",
            comment: "comment",
            description: "description",
            isInvisible: true,
            isNegative: false,
            generic: "generic".data(using: .utf8)!
        )

        do {
            try? keychain.set("value", for: key)

            let attributes = try keychain.attributes(key)

            XCTAssertEqual(attributes.class, .internetPassword)
            XCTAssertEqual(attributes.server, "github.com")
            XCTAssertEqual(attributes.protocolType, .https)
            XCTAssertEqual(attributes.authenticationType, .httpBasic)
            XCTAssertEqual(attributes.accessible, .afterFirstUnlock)
            XCTAssertEqual(attributes.synchronizable, true)
            XCTAssertEqual(attributes.securityDomain, "securityDomain")
            XCTAssertEqual(attributes.label, "label")
            XCTAssertEqual(attributes.comment, "comment")
            XCTAssertEqual(attributes.attrDescription, "description")
            XCTAssertEqual(attributes.isInvisible, true)
            XCTAssertEqual(attributes.isNegative, false)
            XCTAssertNil(attributes.generic)
            // TODO: Investigate why accessGroup has a default value
            XCTAssertEqual(attributes.accessGroup, "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost")
        }
    }
}
