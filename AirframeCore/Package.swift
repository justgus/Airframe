// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AirframeCore",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "AirframeCore",
            targets: ["AirframeCore"]
        )
    ],
    targets: [
        .target(
            name: "AirframeCore",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "AirframeCoreTests",
            dependencies: ["AirframeCore"]
        )
    ]
)
