// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "bytesized.co",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(name: "bytesized", targets: ["bytesized"])
    ],
    dependencies: [
        .package(url: "https://github.com/pvzig/Publish", branch: "master"),
        .package(url: "https://github.com/johnsundell/plot", from: "0.14.0"),
        .package(url: "https://github.com/JohnSundell/Splash.git", from: "0.16.0"),
        .package(url: "https://github.com/pvzig/CommonMark", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "bytesized",
            dependencies: [
                .product(name: "Plot", package: "plot"),
                "Publish",
                "CommonMark",
                "Splash",
            ])
    ]
)
