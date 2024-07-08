//
//  Created by Andriy Slyusar on 2024-07-07.
//  Copyright © 2024 Andriy Slyusar. All rights reserved.
//

import SwiftUI
import SwiftyKeychainKit

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            SwiftUICaseStudyView()
//                .defaultAppKeychainStorage(.default)
//                .defaultAppKeychainStorage(.accessGroupKeychain)
        }
        .defaultAppKeychainStorage(.default)
//        .defaultAppKeychainStorage(.accessGroupKeychain)
    }
}
