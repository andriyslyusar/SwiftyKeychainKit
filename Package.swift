// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwiftyKeychainKit",
    platforms: [
        .iOS(.v10), .macOS(.v10_10), .watchOS(.v4), .macCatalyst(.v13), .tvOS(.v10)
    ],
    products: [
        .library(name: "SwiftyKeychainKit", targets: ["SwiftyKeychainKit"]),
    ],
    targets: [
        .target(name: "SwiftyKeychainKit", path: "Sources")
    ]
)
