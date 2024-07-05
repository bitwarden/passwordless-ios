// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Passwordless",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Passwordless",
            targets: ["Passwordless"]),
    ],
    targets: [
        .target(
            name: "Passwordless"),
        .testTarget(
            name: "PasswordlessTests",
            dependencies: ["Passwordless"],
            resources: [.process("Mocks/Json")]
        ),
    ]
)
