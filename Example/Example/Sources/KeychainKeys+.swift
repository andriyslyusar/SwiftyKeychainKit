//
//  Created by Andriy Slyusar on 2024-07-07.
//  Copyright © 2024 Andriy Slyusar. All rights reserved.
//

import SwiftyKeychainKit

extension KeychainKey {
    static var secret: Keychain.Key<String> { .genericPassword(key: "secret", service: "com.swifty.keychainkit.example") }
}
