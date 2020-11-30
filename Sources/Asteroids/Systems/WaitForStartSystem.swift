//
//  WaitForStartSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 21.11.2020.
//

import FirebladeECS

final class WaitForStartSystem {
    private let creator: EntityCreator
    private let config: GameConfig
    private let games: Family1<GameState>
    private let waits: Family1<WaitForStart>
    private let asteroids: Family1<Asteroid>

    init(creator: EntityCreator, nexus: Nexus, config: GameConfig) {
        self.creator = creator
        self.config = config
        waits = nexus.family(requires: WaitForStart.self)
        games = nexus.family(requires: GameState.self)
        asteroids = nexus.family(requires: Asteroid.self)
    }

    func update() {
        for (waitEntity, waitForStart) in waits.entityAndComponents where waitForStart.startGame {
            for game in games {
                for (asteroidEntity, _) in asteroids.entityAndComponents {
                    creator.destroy(entity: asteroidEntity)
                }
                game.setForStart()
                waitForStart.startGame = false
                creator.destroy(entity: waitEntity)
            }
        }
    }
}
