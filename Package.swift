// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyKeychainKit",
    products: [
        .library(
            name: "SwiftyKeychainKit",
            targets: ["SwiftyKeychainKit"]),
    ],
    targets: [
        .target(
            name: "SwiftyKeychainKit",
            dependencies: [],
            path: "Sources"),
    ]
)
