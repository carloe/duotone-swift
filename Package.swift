// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "duotone",
    platforms: [
      .macOS(.v10_14)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.2.0")
    ],
    targets: [
        .executableTarget(
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
