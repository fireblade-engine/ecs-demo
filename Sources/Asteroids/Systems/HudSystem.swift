//
//  HudSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 21.11.2020.
//

import FirebladeECS

final class HudSystem {
    private let huds: Family2<GameState, Hud>

    init(nexus: Nexus) {
        huds = nexus.family(requiresAll: GameState.self, Hud.self)
    }

    func update() {
        for (gameState, hud) in huds {
            hud.view.setLives(gameState.lives)
            hud.view.setScore(gameState.hits)
        }
    }
}
