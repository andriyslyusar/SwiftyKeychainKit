//
// AttributeTests.swift
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
@testable import SwiftyKeychainKit

class AttributeTests: XCTestCase {

    func testItemClass() {
        let value = ItemClass.genericPassword
        XCTAssertEqual(Attribute.class(value).rawValue.key, String(kSecClass))
        XCTAssertEqual(Attribute.class(value).rawValue.value as! CFString, value.rawValue)
    }

    func testService() {
        let value = "com.swifty.keychain"
        XCTAssertEqual(Attribute.service(value).rawValue.key, String(kSecAttrService))
        XCTAssertEqual(Attribute.service(value).rawValue.value as! String, value)
    }

    func testAccount() {
        let value = "account"
        XCTAssertEqual(Attribute.account(value).rawValue.key, String(kSecAttrAccount))
        XCTAssertEqual(Attribute.account(value).rawValue.value as! String, value)
    }

    func testValueData() {
        let value = "data".data(using: .utf8)!
        XCTAssertEqual(Attribute.valueData(value).rawValue.key, String(kSecValueData))
        XCTAssertEqual(Attribute.valueData(value).rawValue.value as! Data, value)
    }

    func testAccessible() {
        let value = AccessibilityLevel.afterFirstUnlock
        let attr = Attribute.accessible(value)
        XCTAssertEqual(attr.rawValue.key, String(kSecAttrAccessible))
        XCTAssertEqual(attr.rawValue.value as! CFString, value.rawValue)
    }

    func testIsReturnData() {
        XCTAssertEqual(Attribute.isReturnData(true).rawValue.key, String(kSecReturnData))
        XCTAssertTrue(Attribute.isReturnData(true).rawValue.value as! Bool)

        XCTAssertEqual(Attribute.isReturnData(false).rawValue.key, String(kSecReturnData))
        XCTAssertFalse(Attribute.isReturnData(false).rawValue.value as! Bool)
    }

    func test_matchLimit() {
        XCTAssertEqual(Attribute.matchLimit(.one).rawValue.key, String(kSecMatchLimit))
        XCTAssertEqual(Attribute.matchLimit(.one).rawValue.value as! CFString, kSecMatchLimitOne)

        XCTAssertEqual(Attribute.matchLimit(.all).rawValue.key, String(kSecMatchLimit))
        XCTAssertEqual(Attribute.matchLimit(.all).rawValue.value as! CFString, kSecMatchLimitAll)
    }

    func test_accessGroup() {
        let value = "W7JL9XM57U.com.swifty.keychain"
        XCTAssertEqual(Attribute.accessGroup(value).rawValue.key, String(kSecAttrAccessGroup))
        XCTAssertEqual(Attribute.accessGroup(value).rawValue.value as! String, value)
    }

    func test_synchronizable() {
        XCTAssertEqual(Attribute.synchronizable(.any).rawValue.key, String(kSecAttrSynchronizable))
        XCTAssertEqual(Attribute.synchronizable(.any).rawValue.value as! CFString, kSecAttrSynchronizableAny)
    }

    func testAttributeArray_compose_to_dictinary() {
        let array: Attributes = [
            .class(.genericPassword)
        ]
        let resultDict = array.compose() as NSDictionary

        XCTAssertEqual(resultDict.allKeys.count, 1)
        XCTAssertTrue((array.compose() as! Dictionary)[String(kSecClass)] == ItemClass.genericPassword.rawValue)
    }
}
