//
// KeychainSpec.swift
//
// Created by Andriy Slyusar on 2019-09-29.
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
import Quick
import Nimble
@testable import SwiftyKeychainKit

class KeychainSpec: QuickSpec {
     override func spec() {
        describe("Generic password itialiser") {
            context("when use with only required values") {
                it("it inialise all default values correctly") {
                    let keychain = Keychain(service: "com.swifty.keychainkit")

                    expect(keychain.itemClass) == .genericPassword
                    expect(keychain.service) == "com.swifty.keychainkit"
                    expect(keychain.accessible) == .whenUnlocked
                    expect(keychain.accessGroup).to(beNil())
                    expect(keychain.synchronizable) == false
                }

                it("it initialise accessible attribute") {
                    let keychain = Keychain(service: "com.swifty.keychainkit", accessible: .afterFirstUnlock)
                    expect(keychain.accessible) == .afterFirstUnlock
                }

                it("it initialise accessGroup attribute") {
                    let keychain = Keychain(service: "com.swifty.keychainkit", accessGroup: "accessGroup")
                    expect(keychain.accessGroup) == "accessGroup"
                }

                it("it initialise synchronizable attribute") {
                    let keychain = Keychain(service: "com.swifty.keychainkit", synchronizable: true)
                    expect(keychain.synchronizable) == true
                }
            }
        }

        describe("Internet password itialiser") {
            context("when use with only required values") {
                let url = URL(string: "https://www.google.com")!

                it("it inialise all default values correctly") {
                    let keychain = Keychain(server: url, protocolType: .https)

                    expect(keychain.itemClass) == .internetPassword
                    expect(keychain.server) == url
                    expect(keychain.authenticationType) == .default
                    expect(keychain.accessible) == .whenUnlocked
                    expect(keychain.accessGroup).to(beNil())
                    expect(keychain.synchronizable) == false
                    expect(keychain.securityDomain).to(beNil())
                }

                it("it initialise accessible attribute") {
                   let keychain = Keychain(server: url, protocolType: .https, accessible: .afterFirstUnlock)
                   expect(keychain.accessible) == .afterFirstUnlock
                }

                it("it initialise accessGroup attribute") {
                     let keychain = Keychain(server: url, protocolType: .https, accessGroup: "accessGroup")
                     expect(keychain.accessGroup) == "accessGroup"
                }

                it("it initialise synchronizable attribute") {
                    let keychain = Keychain(server: url, protocolType: .https, synchronizable: true)
                    expect(keychain.synchronizable) == true
                }

                it("it initialise accessGroup attribute") {
                     let keychain = Keychain(server: url, protocolType: .https, securityDomain: "securityDomain")
                     expect(keychain.securityDomain) == "securityDomain"
                }
            }
        }
    }
}
