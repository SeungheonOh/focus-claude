// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "focus-overlay",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "focus-overlay",
            path: "Sources/focus-overlay"
        )
    ]
)
