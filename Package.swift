// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TreeArray",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TreeArray",
            targets: ["TreeArray"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/lemire/SwiftWyhash", from: "0.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TreeArray",
            dependencies: [
                .product(name: "SwiftWyhash", package: "SwiftWyhash")
            ]),
        .testTarget(
            name: "TreeArrayTests",
            dependencies: ["TreeArray"]
        ),
        .executableTarget(
            name: "RandomTests",
            dependencies: ["TreeArray"],
            path: "Sources/RandomTests"
        )
    ]
)
