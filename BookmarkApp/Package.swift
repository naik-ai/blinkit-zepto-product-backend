// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BookmarkApp",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "BookmarkApp",
            targets: ["BookmarkApp"]
        )
    ],
    targets: [
        .target(
            name: "BookmarkApp",
            path: "Sources/BookmarkApp"
        ),
        .testTarget(
            name: "BookmarkAppTests",
            dependencies: ["BookmarkApp"],
            path: "Tests/BookmarkAppTests"
        )
    ]
)
