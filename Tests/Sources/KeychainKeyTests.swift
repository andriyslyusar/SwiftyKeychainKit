//
// KeychainKeyTests.swift
//
// Created by Andriy Slyusar on 2022-10-29.
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

class KeychainKeyTests: XCTestCase {
    func testGenericPasswordInitilizer() {
        let key = KeychainKey<Int>.genericPassword(
            key: "key",
            service: "com.swifty.keychainkit",
            accessible: .afterFirstUnlock,
            synchronizable: true,
            label: "label",
            comment: "comment",
            description: "description",
            isInvisible: true,
            isNegative: true,
            generic: "data".data(using: .utf8)!
        )

        XCTAssertEqual(key.key, "key")
        XCTAssertEqual(key.accessible, .afterFirstUnlock)
        XCTAssertEqual(key.synchronizable, true)
        XCTAssertEqual(key.label, "label")
        XCTAssertEqual(key.comment, "comment")
        XCTAssertEqual(key.desc, "description")
        XCTAssertEqual(key.isInvisible, true)
        XCTAssertEqual(key.isNegative, true)

        if case let .genericPassword(attrs) = key {
            XCTAssertEqual(attrs.service, "com.swifty.keychainkit")
            XCTAssertEqual(attrs.generic, "data".data(using: .utf8)!)
        }
    }

    func testInternetPasswordInitilizer() {
        let key = KeychainKey<Int>.internetPassword(
            key: "key",
            accessible: .afterFirstUnlock,
            synchronizable: true,
            protocolType: .http,
            domain: "github.com",
            port: 8080,
            path: "/andriyslyusar/SwiftyKeychainKit/issues",
            authenticationType: .httpBasic,
            securityDomain: "securityDomain",
            label: "label",
            comment: "comment",
            description: "description",
            isInvisible: true,
            isNegative: true
        )

        XCTAssertEqual(key.key, "key")
        XCTAssertEqual(key.accessible, .afterFirstUnlock)
        XCTAssertEqual(key.synchronizable, true)
        XCTAssertEqual(key.label, "label")
        XCTAssertEqual(key.comment, "comment")
        XCTAssertEqual(key.desc, "description")
        XCTAssertEqual(key.isInvisible, true)
        XCTAssertEqual(key.isNegative, true)

        if case let .internetPassword(attrs) = key {
            XCTAssertEqual(attrs.protocolType, .http)
            XCTAssertEqual(attrs.domain, "github.com")
            XCTAssertEqual(attrs.port, 8080)
            XCTAssertEqual(attrs.path, "/andriyslyusar/SwiftyKeychainKit/issues")
            XCTAssertEqual(attrs.authenticationType, .httpBasic)
            XCTAssertEqual(attrs.securityDomain, "securityDomain")
        }
    }

    func testInternetPasswordInitilizerWithURL() {
        let key = KeychainKey<Int>.internetPassword(
            key: "key",
            accessible: .afterFirstUnlock,
            synchronizable: true,
            url: URL(string: "http://github.com:8080/andriyslyusar/SwiftyKeychainKit/issues")!,
            authenticationType: .httpBasic,
            securityDomain: "securityDomain",
            label: "label",
            comment: "comment",
            description: "description",
            isInvisible: true,
            isNegative: true
        )

        XCTAssertEqual(key.key, "key")
        XCTAssertEqual(key.accessible, .afterFirstUnlock)
        XCTAssertEqual(key.synchronizable, true)
        XCTAssertEqual(key.label, "label")
        XCTAssertEqual(key.comment, "comment")
        XCTAssertEqual(key.desc, "description")
        XCTAssertEqual(key.isInvisible, true)
        XCTAssertEqual(key.isNegative, true)

        if case let .internetPassword(attrs) = key {
            XCTAssertEqual(attrs.protocolType, .http)
            XCTAssertEqual(attrs.domain, "github.com")
            XCTAssertEqual(attrs.port, 8080)
            XCTAssertEqual(attrs.path, "/andriyslyusar/SwiftyKeychainKit/issues")
            XCTAssertEqual(attrs.authenticationType, .httpBasic)
            XCTAssertEqual(attrs.securityDomain, "securityDomain")
        }
    }
}
