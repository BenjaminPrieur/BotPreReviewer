// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BotReviewer",
  platforms: [.macOS(.v15)],
  products: [
    .executable(
      name: "BotReviewer",
      targets: ["BotReviewer"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
    .package(url: "https://github.com/mattt/ollama-swift.git", from: "1.4.0")
  ],
  targets: [
    .executableTarget(
      name: "BotReviewer",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        .product(name: "Ollama", package: "ollama-swift")
      ]
    ),
    .testTarget(
      name: "BotReviewerTests",
      dependencies: ["BotReviewer"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
