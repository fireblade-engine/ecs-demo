//
//  GameManagementSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 22.11.2020.
//

import FirebladeECS
import AsteroidsGameLibrary

final class GameManagementSystem {
    private let config: GameConfig
    private let creator: EntityCreator
    private let games: Family<GameState>
    private let spaceships: Family<Spaceship, Position>
    private let asteroids: Family<Asteroid, Position, Collision>
    private let bullets: Family<Bullet, Position, Collision>

    init(creator: EntityCreator, config: GameConfig, nexus: Nexus) {
        self.creator = creator
        self.config = config
        games = nexus.family(requires: GameState.self)
        spaceships = nexus.family(requiresAll: Spaceship.self, Position.self)
        asteroids = nexus.family(requiresAll: Asteroid.self, Position.self, Collision.self)
        bullets = nexus.family(requiresAll: Bullet.self, Position.self, Collision.self)
    }

    func update(time: Double) {
        for (gameEntity, game) in games.entityAndComponents where game.playing {
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
                    gameEntity.modify(GameState.self) { $0.playing = false }
                    creator.createWaitForClick()
                }
            }

            if asteroids.isEmpty && bullets.isEmpty && !spaceships.isEmpty {
                // next level
                // `game` is a copy: track the level locally and write it back
                var level = game.level
                for (_, spaceshipPosition) in spaceships {
                    level += 1
                    gameEntity.modify(GameState.self) { $0.level = level }
                    let asteroidCount = 2 + level
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
