// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "FirebladeECSDemo",
    platforms: [
        .macOS(.v11),
        .iOS(.v11),
        .tvOS(.v11)
    ],
    dependencies: [
        .package(name: "SDL", url: "https://github.com/ctreffs/SwiftSDL2.git", from: "1.4.1"),
        .package(name: "FirebladeECS", url: "https://github.com/fireblade-engine/ecs.git", from: "0.17.5"),
        .package(name: "FirebladeMath", url: "https://github.com/fireblade-engine/math.git", from: "0.13.0")
    ],
    targets: [
        .target(
            name: "SDLKit",
            dependencies: ["SDL"]),
        .target(
            name: "Particles",
            dependencies: ["FirebladeECS", "SDL", "SDLKit"]),
        .target(
            name: "Asteroids",
            dependencies: ["FirebladeECS", "SDL", "SDLKit", "FirebladeMath", "AsteroidsGameLibrary"],
            exclude: ["Resources/source.txt"],
            resources: [.copy("Resources/asteroid.wav"), .copy("Resources/ship.wav"), .copy("Resources/shoot.wav")]),
        .target(name: "AsteroidsGameLibrary",
                dependencies: ["FirebladeMath"])
    ]
)
