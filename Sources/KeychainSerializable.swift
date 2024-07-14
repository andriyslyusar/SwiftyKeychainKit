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
import Security

public protocol KeychainSerializable {
    func encode() throws -> Data

    static func decode(_ data: Data) throws -> Self?
}

extension Int: KeychainSerializable {
    public func encode() throws -> Data {
        Data(from: self)
    }
    
    public static func decode(_ data: Data) throws -> Int? {
        data.convert(type: Int.self)
    }
}

extension String: KeychainSerializable {
    public func encode() throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw KeychainError.conversionError
        }
        return data
    }

    public static func decode(_ data: Data) throws -> String? {
        String(data: data, encoding: .utf8)
    }
}

extension Double: KeychainSerializable {
    public func encode() throws -> Data {
        Data(from: self)
    }

    public static func decode(_ data: Data) throws -> Double? {
        data.convert(type: Double.self)
    }
}

extension Float: KeychainSerializable {
    public func encode() throws -> Data {
        Data(from: self)
    }

    public static func decode(_ data: Data) throws -> Float? {
        data.convert(type: Float.self)
    }
}

extension Bool: KeychainSerializable {
    public func encode() throws -> Data {
        let bytes: [UInt8] = self ? [1] : [0]
        return Data(bytes)
    }

    public static func decode(_ data: Data) throws -> Bool? {
        guard let firstBit = data.first else {
            return nil
        }
        return firstBit == 1
    }
}

extension Data: KeychainSerializable {
    public func encode() throws -> Data {
        self
    }

    public static func decode(_ data: Data) throws -> Data? {
        data
    }
}

public extension KeychainSerializable where Self: Decodable & Encodable {
    func encode() throws -> Data {
        try JSONEncoder().encode(self)
    }

    static func decode(_ data: Data) throws -> Self? {
        try JSONDecoder().decode(Self.self, from: data)
    }
}

public extension KeychainSerializable where Self: NSCoding {
    func encode() throws -> Data {
        // TODO: iOS 13 deprecated +archivedDataWithRootObject:requiringSecureCoding:error:
        NSKeyedArchiver.archivedData(withRootObject: self)
    }

    static func decode(_ data: Data) throws -> Self? {
        // TODO: iOS 13 deprecated +unarchivedObjectOfClass:fromData:error:
        guard let value = NSKeyedUnarchiver.unarchiveObject(with: data) as? Self else {
            throw KeychainError.invalidDataCast
        }
        return value
    }
}

/// https://stackoverflow.com/a/38024025/2845836
extension Data {
    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }

    // TODO: Throw KeychainError.conversionError instead of nil
    func convert<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
}
