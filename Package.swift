// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FocusableButton",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "FocusableButton",
            targets: ["FocusableButton"]
        )
    ],
    targets: [
        .target(
            name: "FocusableButton",
            path: "Sources/FocusableButton"
        )
    ]
)
