// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebladeECSDemo",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v11),
        .tvOS(.v11)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/ctreffs/CSDL2.git", from: "1.1.0"),
		.package(url: "https://github.com/fireblade-engine/ecs.git", from: "0.7.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "FirebladeECSDemo",
            dependencies: ["FirebladeECS", "CSDL2"])
    ]
)
