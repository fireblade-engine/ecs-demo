// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "FirebladeECSDemo",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .tvOS(.v17)
    ],
    dependencies: [
        .package(url: "https://github.com/ctreffs/SwiftSDL2.git", from: "1.4.1"),
        .package(url: "https://github.com/fireblade-engine/ecs.git", from: "1.4.2"),
        .package(url: "https://github.com/fireblade-engine/math.git", from: "1.2.0")
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
                .product(name: "FirebladeECSMacros", package: "ecs"),
                .product(name: "SDL", package: "SwiftSDL2"),
                "SDLKit"
            ]),
        .executableTarget(
            name: "Asteroids",
            dependencies: [
                .product(name: "FirebladeECS", package: "ecs"),
                .product(name: "FirebladeECSMacros", package: "ecs"),
                .product(name: "SDL", package: "SwiftSDL2"),
                "SDLKit",
                .product(name: "FirebladeMath", package: "math"),
                "AsteroidsGameLibrary"
            ],
            exclude: ["Resources/source.txt"],
            resources: [.copy("Resources/asteroid.wav"), .copy("Resources/ship.wav"), .copy("Resources/shoot.wav")]),
        .target(name: "AsteroidsGameLibrary",
                dependencies: [.product(name: "FirebladeMath", package: "math")]),
        .testTarget(name: "ParticlesTests",
                    dependencies: ["Particles", .product(name: "FirebladeECS", package: "ecs")]),
        .testTarget(name: "AsteroidsTests",
                    dependencies: ["Asteroids", .product(name: "FirebladeECS", package: "ecs")])
    ],
    swiftLanguageModes: [.v6]
)
