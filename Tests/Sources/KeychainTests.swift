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
    override func setUp() {
        super.setUp()

        do { try Keychain().removeAll() } catch {}
        do { try Keychain(accessGroup: "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost").removeAll() } catch {}
    }

    // MARK: - Initializers

    func testInitializer() {
        do {
            let keychain = Keychain()
            XCTAssertNil(keychain.accessGroup)
        }

        do {
            let keychain = Keychain(accessGroup: "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost")
            XCTAssertEqual(keychain.accessGroup, "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost")
        }
    }

    func testGetAttributesForGenericPasswordWithDefaultInitilisers() throws {
        let keychain = Keychain()
        let key = KeychainKey<String>.genericPassword(key: "key", service: "com.swifty.keychainkit")

        try? keychain.set("value", for: key)
        let attributes = try keychain.attributes(key)

        XCTAssertEqual(attributes.class, .genericPassword)
        XCTAssertEqual(attributes.service, "com.swifty.keychainkit")
        XCTAssertEqual(attributes.accessible, .whenUnlocked)
        XCTAssertEqual(attributes.synchronizable, false)
        XCTAssertEqual(attributes.accessGroup, "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost")
        XCTAssertNil(attributes.label)
        XCTAssertNil(attributes.comment)
        XCTAssertNil(attributes.attrDescription)
        XCTAssertNil(attributes.isInvisible)
        XCTAssertNil(attributes.isNegative)
        XCTAssertNil(attributes.generic)
    }

    func testGetAttributesForGenericPassword() throws {
        let keychain = Keychain(
            accessGroup: "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost"
        )
        let key = KeychainKey<String>.genericPassword(
            key: "key",
            service: "com.swifty.keychainkit",
            accessible: .accessibleAlways,
            label: "label",
            comment: "comment",
            description: "description",
            isInvisible: true,
            isNegative: false,
            generic: "generic".data(using: .utf8)!
        )

        try keychain.set("value", for: key)
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
        XCTAssertEqual(attributes.accessGroup, "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost")
    }

    func testGetAttributesForInternetPasswordWithDefaultInitilisers() throws {
        let keychain = Keychain()
        let key = KeychainKey<String>.internetPassword(
            key: "key",
            url: URL(string: "https://github.com:8080/SwiftyKeychainKit")!,
            scheme: .https,
            authenticationType: .httpBasic
        )

        try keychain.set("value", for: key)
        let attributes = try keychain.attributes(key)

        XCTAssertEqual(attributes.class, .internetPassword)
        XCTAssertEqual(attributes.server, "github.com")
        XCTAssertEqual(attributes.protocolType, .https)
        XCTAssertEqual(attributes.port, 8080)
        XCTAssertEqual(attributes.path, "/SwiftyKeychainKit")
        XCTAssertEqual(attributes.authenticationType, .httpBasic)
        XCTAssertEqual(attributes.accessible, .whenUnlocked)
        XCTAssertEqual(attributes.synchronizable, false)
        XCTAssertEqual(attributes.securityDomain, "")
        XCTAssertNil(attributes.label)
        XCTAssertNil(attributes.comment)
        XCTAssertNil(attributes.attrDescription)
        XCTAssertNil(attributes.isInvisible)
        XCTAssertNil(attributes.isNegative)
        XCTAssertEqual(attributes.accessGroup, "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost")

        // Check General password specific attributes
        XCTAssertNil(attributes.generic)
    }

    func testGetInternetPasswordAttributes() throws {
        let keychain = Keychain(
            accessGroup: "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost"
        )
        let key = KeychainKey<String>.internetPassword(
            key: "key",
            accessible: .afterFirstUnlock,
            synchronizable: true,
            url: URL(string: "https://github.com:8080/SwiftyKeychainKit")!,
            scheme: .https,
            authenticationType: .httpBasic,
            securityDomain: "securityDomain",
            label: "label",
            comment: "comment",
            description: "description",
            isInvisible: true,
            isNegative: false
        )

        try keychain.set("value", for: key)
        let attributes = try keychain.attributes(key)

        XCTAssertEqual(attributes.class, .internetPassword)
        XCTAssertEqual(attributes.server, "github.com")
        XCTAssertEqual(attributes.protocolType, .https)
        XCTAssertEqual(attributes.port, 8080)
        XCTAssertEqual(attributes.path, "/SwiftyKeychainKit")
        XCTAssertEqual(attributes.authenticationType, .httpBasic)
        XCTAssertEqual(attributes.accessible, .afterFirstUnlock)
        XCTAssertEqual(attributes.synchronizable, true)
        XCTAssertEqual(attributes.securityDomain, "securityDomain")
        XCTAssertEqual(attributes.label, "label")
        XCTAssertEqual(attributes.comment, "comment")
        XCTAssertEqual(attributes.attrDescription, "description")
        XCTAssertEqual(attributes.isInvisible, true)
        XCTAssertEqual(attributes.isNegative, false)
        XCTAssertEqual(attributes.accessGroup, "NS8HLGG733.com.swifty.keychain.tests.host.TestsHost")

        // Check General password specific attributes
        XCTAssertNil(attributes.generic)
    }
}
