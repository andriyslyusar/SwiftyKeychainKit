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

    func testMatchLimitOne() {
        XCTAssertEqual(Attribute.matchLimitOne.rawValue.key, String(kSecMatchLimit))
        XCTAssertEqual(Attribute.matchLimitOne.rawValue.value as! CFString, kSecMatchLimitOne)
    }

    func testMatchLimitAll() {
        XCTAssertEqual(Attribute.matchLimitAll.rawValue.key, String(kSecMatchLimit))
        XCTAssertEqual(Attribute.matchLimitAll.rawValue.value as! CFString, kSecMatchLimitAll)
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
