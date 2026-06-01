// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AICockpit",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .executable(
            name: "aicockpit",
            targets: ["AICockpit"]
        ),
        .library(
            name: "AICockpitKit",
            targets: ["AICockpitKit"]
        )
    ],
    dependencies: [
        .package(path: "../AirframeCore")
    ],
    targets: [
        .executableTarget(
            name: "AICockpit",
            dependencies: ["AICockpitKit"]
        ),
        .target(
            name: "AICockpitKit",
            dependencies: ["AirframeCore"]
        ),
        .testTarget(
            name: "AICockpitKitTests",
            dependencies: ["AICockpitKit"]
        )
    ]
)
