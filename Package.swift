// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MicLock",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "MicLock", path: "Sources/MicLock")
    ]
)
