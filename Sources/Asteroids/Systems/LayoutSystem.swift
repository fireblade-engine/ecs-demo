//
//  LayoutSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 23.11.2020.
//

import FirebladeECS

final class LayoutSystem {
    private let config: GameConfig
    private let huds: Family1<Hud>
    private let waits: Family1<WaitForStart>

    init(config: GameConfig, nexus: Nexus) {
        self.config = config
        huds = nexus.family(requires: Hud.self)
        waits = nexus.family(requires: WaitForStart.self)
    }

    func update() {
        for hud in huds {
            hud.view.set(width: config.width)
        }

        for wait in waits {
            wait.waitForStart.setSize(width: config.width, height: config.height)
        }
    }
}
