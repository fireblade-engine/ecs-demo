//
//  CollisionSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 20.11.2020.
//

import FirebladeECS
import AsteroidsGameLibrary

final class CollisionSystem {
    private let creator: EntityCreator
    private let games: Family<GameState>
    private let spaceships: Family<Spaceship, Position, Collision, Audio>
    private let asteroids: Family<Asteroid, Position, Collision, Audio>
    private let bullets: Family<Bullet, Position, Collision>

    init(creator: EntityCreator, nexus: Nexus) {
        self.creator = creator
        games = nexus.family(requires: GameState.self)
        spaceships = nexus.family(requiresAll: Spaceship.self, Position.self, Collision.self, Audio.self)
        asteroids = nexus.family(requiresAll: Asteroid.self, Position.self, Collision.self, Audio.self)
        bullets = nexus.family(requiresAll: Bullet.self, Position.self, Collision.self)
    }

    func update(time: Double) {
        for (bulletEntity, _, bulletPosition, _) in bullets.entityAndComponents {
            for (asteroidEntity, asteroid, asteroidPosition, asteroidCollision, _) in asteroids.entityAndComponents where Vector
                .distanceSQ(
                    asteroidPosition.position,
                    bulletPosition.position
                ) <= asteroidCollision.radius * asteroidCollision.radius {
                creator.destroy(entity: bulletEntity)
                if asteroidCollision.radius > 10 {
                    creator.createAsteroid(radius: asteroidCollision.radius - 10,
                                           x: asteroidPosition.position.x + .random(in: 0...10) - 5,
                                           y: asteroidPosition.position.y + .random(in: 0...10) - 5)
                    creator.createAsteroid(radius: asteroidCollision.radius - 10,
                                           x: asteroidPosition.position.x + .random(in: 0...10) - 5,
                                           y: asteroidPosition.position.y + .random(in: 0...10) - 5)
                }
                asteroid.fsm.changeState(name: .destroyed)
                asteroidEntity.modify(Audio.self) { $0.play(sound: .explodeAsteroid) }
                games.forEach(writing: GameState.self) { $0.hits += 1 }
                break
            }
        }

        for (spaceshipEntity, spaceship, spaceshipPosition, spaceshipCollision, _) in spaceships.entityAndComponents {
            for (_, asteroidPosition, asteroidCollision, _) in asteroids where Vector.distanceSQ(asteroidPosition.position, spaceshipPosition.position) <=
                (asteroidCollision.radius + spaceshipCollision.radius) * (asteroidCollision.radius + spaceshipCollision.radius) {
                spaceship.fsm.changeState(name: .destoyed)
                spaceshipEntity.modify(Audio.self) { $0.play(sound: .explodeShip) }
                games.forEach(writing: GameState.self) { $0.lives -= 1 }
                break
            }
        }
    }
}
