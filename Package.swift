// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-time-primitives",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(
            name: "Time Primitive",
            targets: ["Time Primitive"]
        ),

        .library(
            name: "Time Format Primitives",
            targets: ["Time Format Primitives"]
        ),

        .library(
            name: "Time Julian Primitives",
            targets: ["Time Julian Primitives"]
        ),

        .library(
            name: "Time Primitives",
            targets: ["Time Primitives"]
        ),
        .library(
            name: "Time Primitives Test Support",
            targets: ["Time Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-primitives/swift-dimension-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-format-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-primitives/swift-formatter-primitives.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Time Primitive",
            dependencies: []
        ),

        .target(
            name: "Time Format Primitives",
            dependencies: [
                "Time Primitive",
                .product(name: "Format Primitives", package: "swift-format-primitives"),
                .product(name: "Formatter Primitives", package: "swift-formatter-primitives"),
            ]
        ),

        .target(
            name: "Time Julian Primitives",
            dependencies: [
                "Time Primitive",
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
            ]
        ),

        .target(
            name: "Time Primitives",
            dependencies: [
                "Time Primitive",
                "Time Format Primitives",
                "Time Julian Primitives",
            ]
        ),

        .testTarget(
            name: "Time Primitives Tests",
            dependencies: [
                "Time Primitive",
                "Time Primitives",
            ]
        ),

        .target(
            name: "Time Primitives Test Support",
            dependencies: [
                "Time Primitives",
                .product(
                    name: "Dimension Primitives Test Support",
                    package: "swift-dimension-primitives"
                ),
            ],
            path: "Tests/Support"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
