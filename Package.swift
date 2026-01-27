// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "DIContainer",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "DIContainer",
            targets: ["DIContainer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0"),
    ],
    targets: [
        // Macro implementation
        .macro(
            name: "DIContainerMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        // Main library
        .target(
            name: "DIContainer",
            dependencies: ["DIContainerMacros"]
        ),
        // Tests
        .testTarget(
            name: "DIContainerTests",
            dependencies: ["DIContainer"]
        ),
        // Macro tests
        .testTarget(
            name: "DIContainerMacrosTests",
            dependencies: [
                "DIContainerMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
