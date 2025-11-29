// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "URLCleanser",
    defaultLocalization: "en",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "URLCleanser",
            targets: ["URLCleanser"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "URLCleanser",
            dependencies: []
        ),
        .testTarget(
            name: "URLCleanserTests",
            dependencies: ["URLCleanser"]
        ),
    ]
)
