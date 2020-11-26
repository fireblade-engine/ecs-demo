//
//  GameManagementSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 22.11.2020.
//

import FirebladeECS
import Library

final class GameManagementSystem {
    private let config: GameConfig
    private let creator: EntityCreator
    private let games: Family1<GameState>
    private let spaceships: Family2<Spaceship, Position>
    private let asteroids: Family3<Asteroid, Position, Collision>
    private let bullets: Family3<Bullet, Position, Collision>

    init(creator: EntityCreator, config: GameConfig, nexus: Nexus) {
        self.creator = creator
        self.config = config
        games = nexus.family(requires: GameState.self)
        spaceships = nexus.family(requiresAll: Spaceship.self, Position.self)
        asteroids = nexus.family(requiresAll: Asteroid.self, Position.self, Collision.self)
        bullets = nexus.family(requiresAll: Bullet.self, Position.self, Collision.self)
    }

    func update(time: Double) {
        for game in games where game.playing {
            if spaceships.isEmpty {
                if game.lives > 0 {
                    let newSpaceshipPosition = Vector(x: config.width * 0.5, y: config.height * 0.5)
                    var clearToAddSpaceship = true
                    for (_, asteroidPosition, asteroidCollision) in asteroids where Vector
                        .distanceSQ(asteroidPosition.position, newSpaceshipPosition) <=
                        (asteroidCollision.radius + 50) * (asteroidCollision.radius + 50) {
                        clearToAddSpaceship = false
                        break
                    }
                    if clearToAddSpaceship {
                        creator.createSpaceship()
                    }
                } else {
                    game.playing = false
                    creator.createWaitForClick()
                }
            }

            if asteroids.isEmpty && bullets.isEmpty && !spaceships.isEmpty {
                // next level
                for (_, spaceshipPosition) in spaceships {
                    game.level += 1
                    let asteroidCount = 2 + game.level
                    for _ in 0 ..< asteroidCount {
                        var position: Vector
                        repeat {
                            position = Vector(
                                x: .random(in: 0...config.width),
                                y: .random(in: 0...config.height)
                            )
                        } while Vector.distanceSQ(position, spaceshipPosition.position) <= 80 * 80
                        creator.createAsteroid(radius: 30, x: position.x, y: position.y)
                    }
                }
            }
        }
    }
}
