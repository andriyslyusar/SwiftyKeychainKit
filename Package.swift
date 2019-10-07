// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwiftyKeychainKit",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "SwiftyKeychainKit", targets: ["SwiftyKeychainKit"]),
    ],
    targets: [
        .target(name: "SwiftyKeychainKit", path: "Sources")
    ]
)
