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
    func testInitilizer() {
        let key = KeychainKey<Int>(
            key: "key",
            label: "label",
            comment: "comment",
            description: "description",
            isInvisible: true,
            isNegative: false,
            generic: "generic".data(using: .utf8)!
        )

        XCTAssertEqual(key.key, "key")
        XCTAssertEqual(key.attributes.label, "label")
        XCTAssertEqual(key.attributes.comment, "comment")
        XCTAssertEqual(key.attributes.aDescription, "description")
        XCTAssertEqual(key.attributes.isInvisible, true)
        XCTAssertEqual(key.attributes.isNegative, false)
        XCTAssertEqual(key.attributes.generic, "generic".data(using: .utf8)!)
    }
}
