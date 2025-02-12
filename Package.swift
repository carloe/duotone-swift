// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "duotone",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "duotone", targets: ["duotone"])
    ],
    dependencies: [
        // Command line argument parsing
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        
        // File system operations
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0"),
        
        // Development dependencies
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.55.5"),
        .package(url: "https://github.com/realm/SwiftLint", from: "0.58.2")
    ],
    targets: [
        .executableTarget(
            name: "duotone",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Files", package: "Files")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "duotoneTests",
            dependencies: ["duotone"]
        )
    ]
)
