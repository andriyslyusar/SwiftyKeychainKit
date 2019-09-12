// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyKeychain",
    products: [
        .library(
            name: "SwiftyKeychain",
            targets: ["SwiftyKeychain"]),
    ],
    targets: [
        .target(
            name: "SwiftyKeychain",
            dependencies: [],
            path: "Sources"),
    ]
)
