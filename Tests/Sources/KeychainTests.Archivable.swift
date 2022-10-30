//
// KeychainTests.Archivable.swift
//
// Created by Andriy Slyusar on 2022-10-27.
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

class KeychainArchivableTests: AbstractKeychainTests<ArchivableObject> {
    override var value1: ArchivableObject! {
        get { ArchivableObject(intProperty: 1) }
        set {}
    }

    override var value2: ArchivableObject! {
        get { ArchivableObject(intProperty: 2) }
        set {}
    }

    override var value3: ArchivableObject! {
        get { ArchivableObject(intProperty: 3) }
        set {}
    }
}

@objc(ArchivableValue)
class ArchivableObject: NSObject, NSCoding, KeychainSerializable {
    var intProperty: Int

    init(intProperty: Int) {
        self.intProperty = intProperty
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(intProperty, forKey: "intProperty")
    }

    required init?(coder aDecoder: NSCoder) {
        intProperty = aDecoder.decodeInteger(forKey: "intProperty")
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let archivableObject = object as? ArchivableObject else {
            return false
        }
        return self.intProperty == archivableObject.intProperty
    }
}
