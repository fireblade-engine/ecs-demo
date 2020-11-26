//
//  MovementSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 21.11.2020.
//

import FirebladeECS
import Library

final class MovementSystem {
    private let config: GameConfig
    private let movements: Family2<Position, Motion>

    init(config: GameConfig, nexus: Nexus) {
        self.config = config
        movements = nexus.family(requiresAll: Position.self, Motion.self)
    }

    func update(time: Double) {
        for (position, motion) in movements {
            position.position += motion.velocity * time

            if position.position.x < 0 {
                position.position.x += config.width
            }

            if position.position.x > config.width {
                position.position.x -= config.width
            }

            if position.position.y < 0 {
                position.position.y += config.height
            }

            if position.position.y > config.height {
                position.position.y -= config.height
            }

            position.rotation += motion.angularVelocity * time

            if motion.damping > 0 {
                let xDamp = abs(cos(position.rotation) * motion.damping * time)
                let yDamp = abs(sin(position.rotation) * motion.damping * time)

                if motion.velocity.x > xDamp {
                    motion.velocity.x -= xDamp
                } else if motion.velocity.x < -xDamp {
                    motion.velocity.x += xDamp
                } else {
                    motion.velocity.x = 0
                }

                if motion.velocity.y > yDamp {
                    motion.velocity.y -= yDamp
                } else if motion.velocity.y < -yDamp {
                    motion.velocity.y += yDamp
                } else {
                    motion.velocity.y = 0
                }
            }
        }
    }
}
