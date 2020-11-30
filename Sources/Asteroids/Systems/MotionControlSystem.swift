//
//  MotionControlSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 21.11.2020.
//

import FirebladeECS
import AsteroidsGameLibrary

final class MotionControlSystem {
    private let isKeyDown: (Int32) -> Bool
    private let motionControls: Family3<MotionControls, Position, Motion>

    init(isKeyDown: @escaping (Int32) -> Bool, nexus: Nexus) {
        self.isKeyDown = isKeyDown
        motionControls = nexus.family(requiresAll: MotionControls.self, Position.self, Motion.self)
    }

    func update(time: Double) {
        for (control, position, motion) in motionControls {
            for key in control.left where isKeyDown(key) {
                position.rotation -= control.rotationRate * time
            }

            for key in control.right where isKeyDown(key) {
                position.rotation += control.rotationRate * time
            }

            for key in control.accelerate where isKeyDown(key) {
                motion.velocity.x += cos(position.rotation) * control.accelerationRate * time
                motion.velocity.y += sin(position.rotation) * control.accelerationRate * time
            }
        }
    }
}
