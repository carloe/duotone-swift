// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "duotone",
    platforms: [
      .macOS(.v10_14),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.1"),
    ],
    targets: [
        .target(
            name: "duotone",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "duotoneTests",
            dependencies: ["duotone"]),
    ]
)
