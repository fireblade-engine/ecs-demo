//
//  SystemsTests.swift
//  FirebladeECSDemo
//

@testable import Asteroids
import AsteroidsGameLibrary
import FirebladeECS
import Foundation
import Testing

/// Reads components back after a system ran: writes through copies would silently change nothing.
@Suite struct SystemsTests {
    let nexus = Nexus()
    let config = GameConfig(width: 800, height: 600)
    let creator: EntityCreator

    init() {
        creator = EntityCreator(nexus: nexus, config: config)
    }

    @Test func movementSystemMovesPositionAndDampsVelocity() throws {
        let system = MovementSystem(config: config, nexus: nexus)
        let entity = nexus.createEntity(with: Position(x: 10, y: 10, rotation: 0),
                                        Motion(velocityX: 100, velocityY: 0, angularVelocity: 2, damping: 10))

        system.update(time: 0.5)

        let position = try #require(entity.get(Position.self))
        #expect(position.position.x == 60)
        #expect(position.rotation == 1)
        let motion = try #require(entity.get(Motion.self))
        #expect(motion.velocity.x < 100)
    }

    @Test func motionControlSystemRotatesAndAccelerates() throws {
        var down: Set<Int32> = []
        let system = MotionControlSystem(isKeyDown: { down.contains($0) }, nexus: nexus)
        let ship = creator.createSpaceship()
        down = try #require(ship.get(MotionControls.self)).accelerate.union(ship.get(MotionControls.self)!.right)

        system.update(time: 0.1)

        #expect(try #require(ship.get(Position.self)).rotation > 0)
        #expect(try #require(ship.get(Motion.self)).velocity.x > 0)
    }

    @Test func bulletAgeSystemCountsDownAndDestroysExpiredBullets() throws {
        let system = BulletAgeSystem(creator: creator, nexus: nexus)
        let young = nexus.createEntity(with: Bullet(lifetime: 1))
        let old = nexus.createEntity(with: Bullet(lifetime: 0.1))

        system.update(time: 0.2)

        #expect(try #require(young.get(Bullet.self)).lifeRemaining == 0.8)
        #expect(nexus.isAlive(young.identifier))
        #expect(!nexus.isAlive(old.identifier))
    }

    @Test func deathThroesSystemCountsDownAndDestroysFinishedEntities() throws {
        let system = DeathThroesSystem(creator: creator, nexus: nexus)
        let dying = nexus.createEntity(with: DeathThroes(duration: 1))
        let dead = nexus.createEntity(with: DeathThroes(duration: 0.1))

        system.update(time: 0.5)

        #expect(try #require(dying.get(DeathThroes.self)).countdown == 0.5)
        #expect(!nexus.isAlive(dead.identifier))
    }

    @Test func gunControlSystemShootsAndResetsTheInterval() throws {
        let system = GunControlSystem(isKeyDown: { _ in true }, creator: creator, nexus: nexus)
        let ship = creator.createSpaceship()
        let bullets = nexus.family(requires: Bullet.self)

        system.update(time: 0.5)

        #expect(bullets.count == 1)
        let gun = try #require(ship.get(Gun.self))
        #expect(gun.shooting)
        #expect(gun.timeSinceLastShot == 0)
        #expect(try #require(ship.get(Audio.self)).toPlay == [.shootGun])
    }

    @Test func collisionSystemCountsHitsAndSplitsAsteroids() throws {
        let game = nexus.createEntity(with: GameState())
        let system = CollisionSystem(creator: creator, nexus: nexus)
        let asteroid = creator.createAsteroid(radius: 30, x: 100, y: 100)
        let bullet = nexus.createEntity(with: Bullet(lifetime: 1), Position(x: 100, y: 100, rotation: 0),
                                        Collision(radius: 0))

        system.update(time: 0.016)

        #expect(try #require(game.get(GameState.self)).hits == 1)
        #expect(!nexus.isAlive(bullet.identifier))
        #expect(try #require(asteroid.get(Audio.self)).toPlay == [.explodeAsteroid])
        #expect(nexus.family(requires: Asteroid.self).count == 3)
    }

    @Test func collisionSystemCostsALifeWhenAnAsteroidHitsTheShip() throws {
        let game = nexus.createEntity(with: GameState())
        game.modify(GameState.self) { $0.lives = 3 }
        let system = CollisionSystem(creator: creator, nexus: nexus)
        let ship = creator.createSpaceship()
        creator.createAsteroid(radius: 30, x: 400, y: 300)

        system.update(time: 0.016)

        #expect(try #require(game.get(GameState.self)).lives == 2)
        #expect(try #require(ship.get(Audio.self)).toPlay == [.explodeShip])
        #expect(ship.has(DeathThroes.self))
    }

    @Test func gameManagementSystemAdvancesTheLevel() throws {
        let game = nexus.createEntity(with: GameState())
        game.modify(GameState.self) { $0.setForStart() }
        let system = GameManagementSystem(creator: creator, config: config, nexus: nexus)
        creator.createSpaceship()

        system.update(time: 0.016)

        #expect(try #require(game.get(GameState.self)).level == 1)
        #expect(nexus.family(requires: Asteroid.self).count == 3)
    }

    @Test func waitForStartSystemStartsTheGameOnClick() throws {
        let game = nexus.createEntity(with: GameState())
        let system = WaitForStartSystem(creator: creator, nexus: nexus, config: config)
        let wait = creator.createWaitForClick()
        let view = try #require(wait.get(WaitForStart.self)).waitForStart

        system.update()
        #expect(nexus.isAlive(wait.identifier))

        view.click()
        #expect(try #require(wait.get(WaitForStart.self)).startGame)
        system.update()

        #expect(!nexus.isAlive(wait.identifier))
        let state = try #require(game.get(GameState.self))
        #expect(state.playing)
        #expect(state.lives == 3)
    }
}
