// swift-tools-version:5.7
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import PackageDescription

let package = Package(
  name: "TreeArray.Benchmarks",
  products: [
    .executable(name: "benchmark", targets: ["benchmark"])
  ],
  dependencies: [
    .package(name: "TreeArray", path: ".."),
    .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.3"),
  ],
  targets: [
    .target(
      name: "Benchmarks",
      dependencies: [
        .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
        .product(name: "TreeArray", package: "TreeArray")
      ],
      path: "Sources/Benchmarks"
    ),
    .executableTarget(
      name: "benchmark",
      dependencies: [
        .target(name: "Benchmarks")
      ],
      path: "Sources/benchmark-tool"
    )
  ]
)
