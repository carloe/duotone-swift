// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "duotone",
    platforms: [
      .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
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
