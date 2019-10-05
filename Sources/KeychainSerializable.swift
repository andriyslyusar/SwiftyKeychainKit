//
// KeychainSerializable.swift
//
// Created by Andriy Slyusar on 2019-08-23.
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

public protocol KeychainSerializable {
    associatedtype T

    static var bridge: KeychainBridge<T> { get }
}

extension Int: KeychainSerializable {
    public static var bridge: KeychainBridge<Int> { return KeychainBridgeInt() }
}

extension String: KeychainSerializable {
    public static var bridge: KeychainBridge<String> { return KeychainBridgeString() }
}

extension Double: KeychainSerializable {
    public static var bridge: KeychainBridge<Double> { return KeychainBridgeDouble() }
}

extension Float: KeychainSerializable {
    public static var bridge: KeychainBridge<Float> { return KeychainBridgeFloat() }
}

extension Bool: KeychainSerializable {
    public static var bridge: KeychainBridge<Bool> { return KeychainBridgeBool() }
}

extension Data: KeychainSerializable {
    public static var bridge: KeychainBridge<Data> { return KeychainBridgeData() }
}

extension KeychainSerializable where Self: Codable {
    public static var bridge: KeychainBridge<Self> { return KeychainBridgeCodable() }
}

extension KeychainSerializable where Self: NSCoding {
    public static var bridge: KeychainBridge<Self> { return KeychainBridgeArchivable() }
}
