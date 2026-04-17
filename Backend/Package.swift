// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "BytesizedCafeBackend",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .executable(name: "Server", targets: ["Server"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-container-plugin", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-configuration.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.5.1"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.33.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.21.1"),
        .package(url: "https://github.com/awslabs/aws-sdk-swift.git", from: "1.6.80"),
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [
                .product(name: "Configuration", package: "swift-configuration")
            ]
        ),
        .executableTarget(
            name: "Server",
            dependencies: [
                "Core",
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "AWSS3", package: "aws-sdk-swift"),
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core"]
        ),
    ]
)
