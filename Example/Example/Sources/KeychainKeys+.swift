//
//  KeychainKeys+.swift
//  Example
//
//  Created by Andriy Slyusar on 2024-07-07.
//  Copyright © 2024 Andriy Slyusar. All rights reserved.
//

import Foundation
import SwiftyKeychainKit

extension KeychainKeys {
    static var secret: KeychainKey<String> { .genericPassword(key: "secret", service: "com.swifty.keychainkit.example") }
}
