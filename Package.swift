// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "duotone",
    platforms: [
      .macOS(.v10_14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.4.1"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0")
    ],
    targets: [
        .target(
            name: "duotone",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Files", package: "Files")
            ]
        ),
        .testTarget(
            name: "duotoneTests",
            dependencies: ["duotone"])
    ]
)
