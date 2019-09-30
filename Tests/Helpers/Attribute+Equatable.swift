//
// Attribute+Equatable.swift
//
// Created by Andriy Slyusar on 2019-09-30.
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
@testable import SwiftyKeychainKit

extension Attribute: Equatable {}

public func ==(lhs: Attribute, rhs: Attribute) -> Bool {
    switch (lhs, rhs) {
    case (.`class`(let a), .`class`(let b)):
        return a == b
    case (.service(let a), .service(let b)):
        return a == b
    case (.account(let a), .account(let b)):
        return a == b
    case (.valueData(let a), .valueData(let b)):
        return a == b
     case (.accessible(let a), .accessible(let b)):
        return a == b
    case (.isReturnData(let a), .isReturnData(let b)):
        return a == b
    case (.matchLimit(let a), .matchLimit(let b)):
        return a == b
    case (.accessGroup(let a), .accessGroup(let b)):
        return a == b
    case (.synchronizable(let a), .synchronizable(let b)):
        return a == b
    case (.server(let a), .server(let b)):
        return a == b
    case (.port(let a), .port(let b)):
        return a == b
    default:
      return false
    }
}

