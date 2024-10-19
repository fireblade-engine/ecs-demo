//
//  EntityCreator.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 19.11.2020.
//

import FirebladeECS
import AsteroidsGameLibrary
import SDL

final class EntityCreator {
    private let nexus: Nexus
    private let config: GameConfig

    init(nexus: Nexus, config: GameConfig) {
        self.nexus = nexus
        self.config = config
    }

    func destroy(entity: Entity) {
        nexus.destroy(entity: entity)
    }

    @discardableResult
    func createGame() -> Entity {
        let hud = HudView()
        return nexus.createEntity()
            .assign(
                GameState(),
                Hud(view: hud),
                Display(renderable: hud),
                Position(x: 0, y: 0, rotation: 0)
            )
    }

    @discardableResult
    func createWaitForClick() -> Entity {
        let waitEntity: Entity = nexus.createEntity()
        let waitView = WaitForStartView()
        waitEntity.assign(
            WaitForStart(waitForStart: waitView),
            Display(renderable: waitView),
            Position(x: 0, y: 0, rotation: 0)
        )
        waitEntity.get(component: WaitForStart.self)?.startGame = false
        return waitEntity
    }

    @discardableResult
    func createAsteroid(radius: Double, x: Double, y: Double) -> Entity {
        let asteroid = nexus.createEntity()
        let fsm = EntityStateMachine<Asteroid.State>(entity: asteroid)
        fsm.createState(name: .alive)
            .addInstance(Motion(velocityX: (.random(in: 0...1) - 0.5) * 4 * (50 - radius),
                                velocityY: (.random(in: 0...1) - 0.5) * 4 * (50 - radius),
                                angularVelocity: .random(in: 0...2) - 1,
                                damping: 0))
            .addInstance(Collision(radius: radius))
            .addInstance(Display(renderable: AsteroidView(radius: radius)))

        let deathView = AsteroidDeathView(radius: radius)
        fsm.createState(name: .destroyed)
            .addInstance(DeathThroes(duration: 3))
            .addInstance(Display(renderable: deathView))
            .addInstance(Animation(animation: deathView))

        asteroid
            .assign(Asteroid(fsm: fsm))
            .assign(Position(x: x, y: y, rotation: 0))
            .assign(Audio())
        fsm.changeState(name: .alive)
        return asteroid
    }

    @discardableResult
    func createSpaceship() -> Entity {
        let spaceship = nexus.createEntity()
        let fsm = EntityStateMachine<Spaceship.State>(entity: spaceship)
        fsm.createState(name: .playing)
            .addInstance(Motion(velocityX: 0, velocityY: 0, angularVelocity: 0, damping: 15))
            .addInstance(
                MotionControls(
                    left: [Int32(SDLK_LEFT.rawValue), Int32(SDLK_a.rawValue)],
                    right: [Int32(SDLK_RIGHT.rawValue), Int32(SDLK_d.rawValue)],
                    accelerate: [Int32(SDLK_UP.rawValue), Int32(SDLK_w.rawValue)],
                    accelerationRate: 100,
                    rotationRate: 3
                )
            )
            .addInstance(Gun(offsetX: 8, offsetY: 0, minimumShotInterval: 0.3, bulletLifetime: 2))
            .addInstance(GunControls(trigger: Int32(SDLK_SPACE.rawValue)))
            .addInstance(Collision(radius: 9))
            .addInstance(Display(renderable: SpaceshipView()))

        let deathView = SpaceshipDeathView()
        fsm.createState(name: .destoyed)
            .addInstance(DeathThroes(duration: 5))
            .addInstance(Display(renderable: deathView))
            .addInstance(Animation(animation: deathView))

        spaceship.assign(
            Spaceship(fsm: fsm),
            Position(x: config.width * 0.5, y: config.height * 0.5, rotation: 0),
            Audio()
        )

        fsm.changeState(name: .playing)
        return spaceship
    }

    @discardableResult
    func createBullet(gun: Gun, parentPosition: Position) -> Entity {
        let cos = AsteroidsGameLibrary.cos(parentPosition.rotation)
        let sin = AsteroidsGameLibrary.sin(parentPosition.rotation)
        return nexus
            .createEntity()
            .assign(
                Bullet(lifetime: gun.bulletLifetime),
                Position(
                    x: cos * gun.offsetFromParent.x - sin * gun.offsetFromParent.y + parentPosition.position.x,
                    y: sin * gun.offsetFromParent.x + cos * gun.offsetFromParent.y + parentPosition.position.y,
                    rotation: 0
                ),
                Collision(radius: 0),
                Motion(velocityX: cos * 150, velocityY: sin * 150, angularVelocity: 0, damping: 0),
                Display(renderable: BulletView()
                )
            )
    }
}
