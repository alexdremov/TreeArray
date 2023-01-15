// swift-tools-version:5.7
import PackageDescription

let package = Package(
  name: "TreeArray.Benchmarks",
  products: [
    .executable(name: "benchmark", targets: ["benchmark"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.3"),
    .package(name: "TreeArray", path: ".."),
  ],
  targets: [
    .target(
      name: "Benchmarks",
      dependencies: [
        .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
        .product(name: "TreeArray", package: "TreeArray")
      ]
    ),
    .executableTarget(
      name: "benchmark",
      dependencies: [
        "Benchmarks"
      ],
      path: "Sources/benchmark-tool"
    )
  ]
)
