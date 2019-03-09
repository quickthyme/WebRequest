// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "WebRequest",
    products: [
        .library(name: "WebRequest", targets: ["WebRequest"])
    ],
    dependencies: [],
    targets: [
        .target(name: "WebRequest", dependencies: []),
        .testTarget(name: "WebRequestTests", dependencies: ["WebRequest"]),
    ]
)
