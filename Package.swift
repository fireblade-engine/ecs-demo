// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "FirebladeECSDemo",
    platforms: [
        .macOS(.v10_14),
        .iOS(.v11),
        .tvOS(.v11)
    ],
    dependencies: [
        .package(name: "SDL2", url: "https://github.com/ctreffs/SwiftSDL2.git", from: "1.3.2"),
        .package(name: "FirebladeECS", url: "https://github.com/fireblade-engine/ecs.git", from: "0.17.5"),
        .package(name: "FirebladeMath", url: "https://github.com/fireblade-engine/math.git", from: "0.13.0")
    ],
    targets: [
        .target(
            name: "SDLKit",
            dependencies: ["SDL2"]),
        .target(
            name: "Particles",
            dependencies: ["FirebladeECS", "SDL2", "SDLKit"]),
        .target(
            name: "Asteroids",
            dependencies: ["FirebladeECS", "SDL2", "SDLKit", "FirebladeMath", "AsteroidsGameLibrary"],
            exclude: ["Resources/source.txt"],
            resources: [.copy("Resources/asteroid.wav"), .copy("Resources/ship.wav"), .copy("Resources/shoot.wav")]),
        .target(name: "AsteroidsGameLibrary",
                dependencies: ["FirebladeMath"])
    ]
)
