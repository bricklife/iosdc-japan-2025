// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "gba-vblank",
  products: [
    .executable(
      name: "Game",
      targets: ["Game"]
    )
  ],
  targets: [
    .executableTarget(
      name: "Game",
      dependencies: [
        "Support"
      ]
    ),
    .target(name: "Support"),
  ]
)
