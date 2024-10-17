// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "conet_libs",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    dependencies: [
        //Dependencies
    ],
    targets: [
        .target(
            name: "YourTargetName",
            dependencies: []),
        .testTarget(
            name: "YourTargetNameTests",
            dependencies: ["YourTargetName"]),
    ]
)

