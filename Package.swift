// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DoomsdayRule",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DoomsdayRule",
            targets: ["DoomsdayRule"]),
        .executable(
            name: "doomsday",
            targets: ["DoomsdayRuleCLI"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.2.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DoomsdayRule",
            dependencies: []),
        .executableTarget(
            name: "DoomsdayRuleCLI",
            dependencies: [
                "DoomsdayRule",
                "Rainbow",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "DoomsdayRuleTests",
            dependencies: ["DoomsdayRule"]),
    ]
)
