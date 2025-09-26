// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "rpi-4b-blink-volatile",
  products: [
    .executable(name: "Application", targets: ["Application"])
  ],
  targets: [
    .executableTarget(
      name: "Application",
      dependencies: [
        "Support",
      ]),
    .target(name: "Support"),
  ])
