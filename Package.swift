// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleanReversi",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "CleanReversi",
            targets: ["CleanReversi"]),
        .library(
            name: "CleanReversiAsync",
            targets: ["CleanReversiAsync"]),
        .library(
            name: "CleanReversiAI",
            targets: ["CleanReversiAI"]),
        .library(
            name: "CleanReversiApp",
            targets: ["CleanReversiApp"]),
        .library(
            name: "CleanReversiGateway",
            targets: ["CleanReversiGateway"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "CleanReversi",
            dependencies: []),
        .target(
            name: "CleanReversiAsync",
            dependencies: []),
        .target(
            name: "CleanReversiAI",
            dependencies: ["CleanReversi", "CleanReversiAsync"]),
        .target(
            name: "CleanReversiApp",
            dependencies: ["CleanReversi", "CleanReversiAsync"]),
        .target(
            name: "CleanReversiGateway",
            dependencies: ["CleanReversiApp"]),
        .testTarget(
            name: "CleanReversiTests",
            dependencies: ["CleanReversi"]),
        .testTarget(
            name: "CleanReversiAsyncTests",
            dependencies: ["CleanReversiAsync"]),
        .testTarget(
            name: "CleanReversiAppTests",
            dependencies: ["CleanReversiApp"]),
        .testTarget(
            name: "CleanReversiGatewayTests",
            dependencies: ["CleanReversiGateway"]),
    ]
)
