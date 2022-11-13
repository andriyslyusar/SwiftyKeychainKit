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
    func testKeychainAttributeElemet() {
        do {
            let attribute = KeychainAttribute.class(.genericPassword)
            XCTAssertEqual(attribute.element.key, kSecClass)
            XCTAssertEqual(attribute.element.value as! CFString, ItemClass.genericPassword.rawValue)
        }

        do {
            let attribute = KeychainAttribute.class(.internetPassword)
            XCTAssertEqual(attribute.element.key, kSecClass)
            XCTAssertEqual(attribute.element.value as! CFString, ItemClass.internetPassword.rawValue)
        }
    }

    func testKeychainCreationDateAttribute() {
        let date = Date()

        do {
            let attribute = KeychainAttribute.creationDate(date)
            XCTAssertEqual(attribute.element.key, kSecAttrCreationDate)
            XCTAssertEqual(attribute.element.value as! Date, date)
            XCTAssertEqual([attribute].creationDate, date)
        }

        do {
            let attribute = KeychainAttribute(key: String(kSecAttrCreationDate), value: date)!
            XCTAssertEqual(attribute.element.key, kSecAttrCreationDate)
            XCTAssertEqual(attribute.element.value as! Date, date)
            XCTAssertEqual([attribute].creationDate, date)
        }
    }

    func testKeychainModificatioDateAttribute() {
        let date = Date()

        do {
            let attribute = KeychainAttribute.modificationDate(date)
            XCTAssertEqual(attribute.element.key, kSecAttrModificationDate)
            XCTAssertEqual(attribute.element.value as! Date, date)
            XCTAssertEqual([attribute].modificationDate, date)
        }

        do {
            let attribute = KeychainAttribute(key: String(kSecAttrModificationDate), value: date)!
            XCTAssertEqual(attribute.element.key, kSecAttrModificationDate)
            XCTAssertEqual(attribute.element.value as! Date, date)
            XCTAssertEqual([attribute].modificationDate, date)
        }
    }

    func testKeychainAttributeInitializer() {
        XCTAssertEqual(
            KeychainAttribute(key: String(kSecClass), value: ItemClass.genericPassword.rawValue),
            KeychainAttribute.class(.genericPassword)
        )
        XCTAssertEqual(
            KeychainAttribute(key: String(kSecClass), value: ItemClass.internetPassword.rawValue),
            KeychainAttribute.class(.internetPassword)
        )
    }
}
