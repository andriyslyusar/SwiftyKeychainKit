//
// KeychainTestable.swift
//
// Created by Andriy Slyusar on 2019-09-28.
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
import Nimble
import Quick
@testable import SwiftyKeychainKit

protocol SerializableSpec {
    associatedtype Serializable: KeychainSerializable & Equatable

    var value: Serializable.T { get }
    var updateValue: Serializable.T { get }
    var defaultValue: Serializable.T { get }
}

extension SerializableSpec where Serializable.T: Equatable, Serializable.T == Serializable {
    func testGenericPassword() {
        describe("persist as generic password") {
            context("when keychain has default attributes") {
                testKeychainOperation(keychain: Keychain(service: keychainService))
            }

    //        context("when keychain has access group") {
    //            testKeychainOperation(keychain: Keychain(service: "com.swifty.keychainkit", accessGroup: keychainAccessGroup))
    //        }

            context("when keychain is synchronizable") {
                testKeychainOperation(keychain: Keychain(service: keychainService, synchronizable: true))
            }

//            context("when keychain has label") {
//                var keychain = Keychain(service: keychainService)
//                keychain.label = keychainLabel
//
//                testKeychainOperation(keychain: keychain)
//            }

//            context("when keychain has comment") {
//                var keychain = Keychain(service: keychainService)
//                keychain.comment = keychainComment
//
//                testKeychainOperation(keychain: keychain)
//            }
//
//            context("when keychain has description") {
//                var keychain = Keychain(service: keychainService)
//                keychain.attrDescription = keychainDescription
//
//                testKeychainOperation(keychain: keychain)
//            }
//
//            context("when keychain has isInvisible attribute") {
//                var keychain = Keychain(service: keychainService)
//                keychain.isInvisible = true
//
//                testKeychainOperation(keychain: keychain)
//            }
//
//            context("when keychain has isNegative attribute") {
//                var keychain = Keychain(service: keychainService)
//                keychain.isNegative = true
//
//                testKeychainOperation(keychain: keychain)
//            }
        }
    }

    func testInternetPassword() {
        describe("persist as internet password") {
            context("when keychain has default attributes") {
                testKeychainOperation(keychain: Keychain(server: keychainUrl, protocolType: .https))
            }

//            context("when keychain has access group") {
//                testKeychainOperation(keychain: Keychain(server: keychainUrl,
//                                                         protocolType: .https,
//                                                         accessGroup: keychainAccessGroup))
//            }

            context("when keychain has access group attribute") {
                testKeychainOperation(keychain: Keychain(server: keychainUrl, protocolType: .https, securityDomain: keychainSecurityDomain))
            }

            context("when keychain is synchronizable attribute") {
                testKeychainOperation(keychain: Keychain(server: keychainUrl, protocolType: .https, synchronizable: true))
            }

//            context("when keychain has label attribute") {
//                var keychain = Keychain(server: keychainUrl, protocolType: .https)
//                keychain.label = keychainLabel
//
//                testKeychainOperation(keychain: keychain)
//            }

//            context("when keychain has comment attribute") {
//                var keychain = Keychain(server: keychainUrl, protocolType: .https)
//                keychain.comment = keychainComment
//
//                testKeychainOperation(keychain: keychain)
//            }
//
//            context("when keychain has description attribute") {
//                var keychain = Keychain(server: keychainUrl, protocolType: .https)
//                keychain.attrDescription = keychainDescription
//
//                testKeychainOperation(keychain: keychain)
//            }
//
//            context("when keychain has isInvisible attribute") {
//                var keychain = Keychain(server: keychainUrl, protocolType: .https)
//                keychain.isInvisible = true
//
//                testKeychainOperation(keychain: keychain)
//            }
//
//            context("when keychain has isNegative attribute") {
//                var keychain = Keychain(server: keychainUrl, protocolType: .https)
//                keychain.isNegative = true
//
//                testKeychainOperation(keychain: keychain)
//            }
        }
    }

    private func testKeychainOperation(keychain: Keychain) {
        describe("its perfom all operations") {
            let key = KeychainKey<Serializable>(key: "key")
            let anotherKey = KeychainKey<Serializable>(key: "anotherKey")

            beforeEach {
                try? keychain.removeAll()
            }

            it("it set a value without error") {
                expect { try keychain.set(self.value, for: key) }.notTo(throwError())
            }

            it("it return nil for unset keychain item") {
                expect { try keychain.get(key) }.to(beNil())
            }

            it("it remove single keychain item") {
                try? keychain.set(self.value, for: key)
                try? keychain.set(self.value, for: anotherKey)

                try? keychain.remove(key)

                expect { try keychain.get(key) }.to(beNil())
                expect { try keychain.get(anotherKey) }.to(equal(self.value))
            }

            it("it remove all keychain item") {
                try? keychain.set(self.value, for: key)
                try? keychain.set(self.value, for: anotherKey)

                try? keychain.removeAll()

                expect { try keychain.get(key) }.to(beNil())
                expect { try keychain.get(anotherKey) }.to(beNil())
            }

            context("when value set in keychain") {
                beforeEach {
                    try? keychain.removeAll()
                    try? keychain.set(self.value, for: key)
                }

                it("it get a value with get function") {
                    expect { try keychain.get(key) }.notTo(throwError())
                    expect { try keychain.get(key) }.to(equal(self.value))
                }

                it("it get a value with subscrit") {
                    expect { try keychain[key].get() }.notTo(throwError())
                    expect { try keychain[key].get() }.to(equal(self.value))
                }

                it("it get a value with dynamicCallable") {
                    expect { try keychain(key).get() }.notTo(throwError())
                    expect { try keychain(key).get() }.to(equal(self.value))
                }
            }

            context("when value update in keychain") {
                beforeEach {
                    try? keychain.removeAll()
                    try? keychain.set(self.value, for: key)
                    try? keychain.set(self.updateValue, for: key)
                }

                it("it get a value with get function") {
                    expect { try keychain.get(key) }.notTo(throwError())
                    expect { try keychain.get(key) }.to(equal(self.updateValue))
                }

                it("it get a value with subscrit") {
                    expect { try keychain[key].get() }.notTo(throwError())
                    expect { try keychain[key].get() }.to(equal(self.updateValue))
                }

                it("it get a value with dynamicCallable") {
                    expect { try keychain(key).get() }.notTo(throwError())
                    expect { try keychain(key).get() }.to(equal(self.updateValue))
                }
            }

            context("when value missing in keychian but default value provided") {
                beforeEach {
                    try? keychain.removeAll()
                }

                it("it return default value in response using get fuction") {
                    expect { try keychain.get(key, default: self.defaultValue) }.notTo(throwError())
                    expect { try keychain.get(key, default: self.defaultValue) }.to(equal(self.defaultValue))
                }

                it("it return default value in response using subscrit") {
                    expect { try keychain[key, default: self.defaultValue].get() }.notTo(throwError())
                    expect { try keychain[key, default: self.defaultValue].get() }.to(equal(self.defaultValue))
                }
            }
        }
    }
}
