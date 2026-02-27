// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-time-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        // MARK: - Core
        .library(
            name: "Time Primitives Core",
            targets: ["Time Primitives Core"]
        ),
        // MARK: - Variants
        .library(
            name: "Time Julian Primitives",
            targets: ["Time Julian Primitives"]
        ),
        // MARK: - Umbrella
        .library(
            name: "Time Primitives",
            targets: ["Time Primitives"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-dimension-primitives"),
        .package(path: "../swift-formatting-primitives"),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "Time Primitives Core",
            dependencies: [
                .product(name: "Formatting Primitives", package: "swift-formatting-primitives"),
            ]
        ),

        // MARK: - Variants
        .target(
            name: "Time Julian Primitives",
            dependencies: [
                "Time Primitives Core",
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Time Primitives",
            dependencies: [
                "Time Primitives Core",
                "Time Julian Primitives",
            ]
        ),

        // MARK: - Tests
        .testTarget(
            name: "Time Primitives Tests",
            dependencies: [
                "Time Primitives",
            ]
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
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
