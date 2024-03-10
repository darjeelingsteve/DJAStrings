// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DJAStrings",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-format.git", from: "508.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "DJAStrings",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftFormat", package: "swift-format")
            ],
            resources: [
                .copy("Resources/Swift Keywords.json")
            ]
        ),
        .testTarget(
            name: "DJAStringsTests",
            dependencies: ["DJAStrings"],
            resources: [
                .copy("Resources/XCStrings Files"),
                .copy("Resources/Custom.swift-format")
            ])
    ]
)
