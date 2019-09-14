//
// KeychainEnumsTests.swift
//
// Created by Andriy Slyusar on 2019-09-14.
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

class KeychainEnumsTests: XCTestCase {

    func testItemClass_value() {
        XCTAssertEqual(ItemClass.genericPassword.rawValue, kSecClassGenericPassword)
        XCTAssertEqual(ItemClass.internetPassword.rawValue, kSecClassInternetPassword)
    }

    func testAccessibilityLevel_value() {
        XCTAssertEqual(AccessibilityLevel.whenPasscodeSetThisDeviceOnly.rawValue, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
        XCTAssertEqual(AccessibilityLevel.unlockedThisDeviceOnly.rawValue, kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        XCTAssertEqual(AccessibilityLevel.whenUnlocked.rawValue, kSecAttrAccessibleWhenUnlocked)
        XCTAssertEqual(AccessibilityLevel.afterFirstUnlockThisDeviceOnly.rawValue, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
        XCTAssertEqual(AccessibilityLevel.afterFirstUnlock.rawValue, kSecAttrAccessibleAfterFirstUnlock)
        XCTAssertEqual(AccessibilityLevel.alwaysThisDeviceOnly.rawValue, kSecAttrAccessibleAlwaysThisDeviceOnly)
        XCTAssertEqual(AccessibilityLevel.accessibleAlways.rawValue, kSecAttrAccessibleAlways)
    }
}
