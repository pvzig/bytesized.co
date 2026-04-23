// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "BytesizedCafe",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "BytesizedCafe", targets: ["BytesizedCafe"])
    ],
    dependencies: [
        .package(url: "https://github.com/swiftwasm/JavaScriptKit.git", from: "0.50.2"),
        .package(url: "https://github.com/pvzig/parcel", from: "0.2.1"),
    ],
    targets: [
        .executableTarget(
            name: "BytesizedCafe",
            dependencies: [
                .product(name: "JavaScriptEventLoop", package: "JavaScriptKit"),
                .product(name: "JavaScriptKit", package: "JavaScriptKit"),
                .product(name: "Parcel", package: "parcel"),
            ]
        )
    ]
)
