// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FirebladeECSDemo",
    platforms: [
        .macOS(.v14),
        .iOS(.v14),
        .tvOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/ctreffs/SwiftSDL2.git", from: "1.4.1"),
        .package(url: "https://github.com/fireblade-engine/ecs.git", from: "1.1.2"),
        .package(url: "https://github.com/fireblade-engine/math.git", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "SDLKit",
            dependencies: [
                .product(name: "SDL", package: "SwiftSDL2")
            ]),
        .executableTarget(
            name: "Particles",
            dependencies: [
                .product(name: "FirebladeECS", package: "ecs"),
                .product(name: "SDL", package: "SwiftSDL2"),
                "SDLKit"
            ]),
        .executableTarget(
            name: "Asteroids",
            dependencies: [
                .product(name: "FirebladeECS", package: "ecs"),
                .product(name: "SDL", package: "SwiftSDL2"),
                "SDLKit",
                .product(name: "FirebladeMath", package: "math"),
                "AsteroidsGameLibrary"
            ],
            exclude: ["Resources/source.txt"],
            resources: [.copy("Resources/asteroid.wav"), .copy("Resources/ship.wav"), .copy("Resources/shoot.wav")]),
        .target(name: "AsteroidsGameLibrary",
                dependencies: [.product(name: "FirebladeMath", package: "math")])
    ]
)
