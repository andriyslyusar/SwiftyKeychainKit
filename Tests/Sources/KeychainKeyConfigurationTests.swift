//
// KeychainKeyConfigurationTests.swift
//
// Created by Andriy Slyusar on 2024-07-28.
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

class KeychainKeyConfigurationTests: XCTestCase {
    func testDefaultKeychainKeyConfiguration() {
        let configuration = KeychainKeyConfiguration.shared

        let genericPassword = Keychain.Key<String>.genericPassword(key: "key1")
        let internetPassword = Keychain.Key<String>.internetPassword(key: "key2", url: URL(string: "https://www.google.com")!)

        // Assert KeychainKeyConfiguration
        XCTAssertEqual(configuration.service, "com.swifty.keychain.tests.host.TestsHost")
        XCTAssertEqual(configuration.accessible, AccessibilityLevel.whenUnlocked)
        XCTAssertEqual(configuration.synchronizable, false)
        XCTAssertEqual(configuration.authenticationType, AuthenticationType.default)

        // Assert genericPassword
        if case let .genericPassword(attrs) = genericPassword {
            XCTAssertEqual(attrs.service, "com.swifty.keychain.tests.host.TestsHost")
            XCTAssertEqual(attrs.accessible, AccessibilityLevel.whenUnlocked)
            XCTAssertEqual(attrs.synchronizable, false)
        }

        // Assert internetPassword
        if case let .internetPassword(attrs) = internetPassword {
            XCTAssertEqual(attrs.accessible, AccessibilityLevel.whenUnlocked)
            XCTAssertEqual(attrs.synchronizable, false)
            XCTAssertEqual(attrs.authenticationType, AuthenticationType.default)
        }
    }

    func testModifyKeychainKeyConfiguration() {
        let configuration = KeychainKeyConfiguration.shared

        defer {
            configuration.service = "com.swifty.keychain.tests.host.TestsHost"
            configuration.accessible = AccessibilityLevel.whenUnlocked
            configuration.synchronizable = false
            configuration.authenticationType = AuthenticationType.default
        }

        configuration.service = "com.google"
        configuration.accessible = AccessibilityLevel.afterFirstUnlock
        configuration.synchronizable = true
        configuration.authenticationType = AuthenticationType.httpBasic

        let genericPassword = Keychain.Key<String>.genericPassword(key: "key1")
        let internetPassword = Keychain.Key<String>.internetPassword(key: "key2", url: URL(string: "https://www.google.com")!)

        XCTAssertEqual(configuration.service, "com.google")
        XCTAssertEqual(configuration.accessible, AccessibilityLevel.afterFirstUnlock)
        XCTAssertEqual(configuration.synchronizable, true)
        XCTAssertEqual(configuration.authenticationType, AuthenticationType.httpBasic)

        // Assert genericPassword
        if case let .genericPassword(attrs) = genericPassword {
            XCTAssertEqual(attrs.service, "com.google")
            XCTAssertEqual(attrs.accessible, AccessibilityLevel.afterFirstUnlock)
            XCTAssertEqual(attrs.synchronizable, true)
        }

        // Assert internetPassword
        if case let .internetPassword(attrs) = internetPassword {
            XCTAssertEqual(attrs.accessible, AccessibilityLevel.afterFirstUnlock)
            XCTAssertEqual(attrs.synchronizable, true)
            XCTAssertEqual(attrs.authenticationType, AuthenticationType.httpBasic)
        }
    }
}
