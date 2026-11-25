// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "JonContextMenu",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "JonContextMenu", targets: ["JonContextMenu"])
    ],
    targets: [
        .target(name: "JonContextMenu"),
        .testTarget(name: "JonContextMenuTests", dependencies: ["JonContextMenu"])
    ]
)
