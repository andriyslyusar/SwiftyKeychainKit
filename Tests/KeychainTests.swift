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
