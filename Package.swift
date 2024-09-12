// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "SwiftyKeychainKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "SwiftyKeychainKit", targets: ["SwiftyKeychainKit"]),
    ],
    targets: [
        .target(name: "SwiftyKeychainKit", path: "Sources")
    ]
)

for target in package.targets {
    target.swiftSettings = target.swiftSettings ?? []
    target.swiftSettings?.append(
        contentsOf: [
            .enableExperimentalFeature("StrictConcurrency"),
            .enableUpcomingFeature("ExistentialAny")
        ]
    )
}
