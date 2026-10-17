//
//  EntityCreatorTests.swift
//  FirebladeECSDemo
//

@testable import Asteroids
import FirebladeECSMacros
import Foundation
import Testing

@Suite struct EntityCreatorTests {
    let nexus = Nexus()
    let creator: EntityCreator

    init() {
        creator = EntityCreator(nexus: nexus, config: GameConfig(width: 800, height: 600))
    }

    @Test func asteroidStateMachineSwapsComponents() throws {
        let asteroid = creator.createAsteroid(radius: 30, x: 10, y: 20)

        #expect(asteroid.has(Motion.self))
        #expect(asteroid.has(Collision.self))
        #expect(!asteroid.has(DeathThroes.self))
        #expect(asteroid.get(Position.self)?.position == [10, 20])

        try #require(asteroid.get(Asteroid.self)).fsm.changeState(name: .destroyed)

        #expect(!asteroid.has(Motion.self))
        #expect(!asteroid.has(Collision.self))
        #expect(asteroid.has(DeathThroes.self))
        #expect(asteroid.has(Display.self))
    }

    @Test func bulletIsFiredFromTheGunOffset() throws {
        let gun = Gun(offsetX: 8, offsetY: 0, minimumShotInterval: 0.3, bulletLifetime: 2)
        let bullet = creator.createBullet(gun: gun, parentPosition: Position(x: 100, y: 100, rotation: 0))

        #expect(bullet.get(Bullet.self)?.lifeRemaining == 2)
        #expect(bullet.get(Position.self)?.position == [108, 100])
        #expect(bullet.get(Motion.self)?.velocity == [150, 0])
    }

    @Test func snapshotSkipsRuntimeOnlyComponents() throws {
        let spaceship = creator.createSpaceship()
        spaceship.get(Audio.self)?.play(sound: .shootGun)

        var encoder = JSONEncoder()
        let data = try nexus.encodeSnapshot(using: &encoder, handling: .skip)

        let restored = Nexus()
        try restored.register([Position.self, Motion.self, MotionControls.self, Gun.self, GunControls.self,
                               Collision.self, Audio.self])
        var decoder = JSONDecoder()
        try restored.restoreSnapshot(from: data, using: &decoder)

        let copy = restored.entity(from: spaceship.identifier)
        #expect(copy.get(Position.self)?.position == [400, 300])
        #expect(copy.get(Gun.self)?.bulletLifetime == 2)
        #expect(copy.get(MotionControls.self)?.accelerationRate == 100)
        // `@ComponentIgnored` queue is not persisted
        #expect(copy.get(Audio.self)?.toPlay == [])
        // views and state machines are runtime-only
        #expect(!copy.has(Spaceship.self))
        #expect(!copy.has(Display.self))
    }
}
