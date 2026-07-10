// swift-tools-version: 6.3.3

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
        // MARK: - Namespace + foundational types (per [MOD-017])
        .library(
            name: "Time Primitive",
            targets: ["Time Primitive"]
        ),
        // MARK: - Sub-namespaces (per [MOD-031])
        .library(
            name: "Time Format Primitives",
            targets: ["Time Format Primitives"]
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
        .library(
            name: "Time Primitives Test Support",
            targets: ["Time Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-dimension-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-format-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-formatter-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Namespace + foundational types (per [MOD-017]; zero external deps — the invariant)
        .target(
            name: "Time Primitive",
            dependencies: []
        ),

        // MARK: - Sub-namespaces (per [MOD-031])
        .target(
            name: "Time Format Primitives",
            dependencies: [
                "Time Primitive",
                .product(name: "Format Primitives", package: "swift-format-primitives"),
                .product(name: "Formatter Primitives", package: "swift-formatter-primitives"),
            ]
        ),

        // MARK: - Variants
        .target(
            name: "Time Julian Primitives",
            dependencies: [
                "Time Primitive",
                .product(name: "Dimension Primitives", package: "swift-dimension-primitives"),
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Time Primitives",
            dependencies: [
                "Time Primitive",
                "Time Format Primitives",
                "Time Julian Primitives",
            ]
        ),

        // MARK: - Tests
        .testTarget(
            name: "Time Primitives Tests",
            dependencies: [
                "Time Primitive",
                "Time Primitives",
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Time Primitives Test Support",
            dependencies: [
                "Time Primitives",
                .product(name: "Dimension Primitives Test Support", package: "swift-dimension-primitives"),
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
