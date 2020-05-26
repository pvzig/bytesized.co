// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "bytesized.co",
    products: [
        .executable(name: "bytesized", targets: ["bytesized"])
    ],
    dependencies: [
        .package(url: "https://github.com/pvzig/Publish", .branch("master")),
        .package(name: "Plot", url: "https://github.com/johnsundell/plot.git", from: "0.8.0"),
        .package(name: "CommonMark", url: "https://github.com/SwiftDocOrg/CommonMark", from: "0.4.0")
    ],
    targets: [
        .target(
            name: "bytesized",
            dependencies: [
                "Plot",
                "Publish",
                "CommonMark"
            ])
    ]
)
