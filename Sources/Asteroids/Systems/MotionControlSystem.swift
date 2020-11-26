//
//  MotionControlSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 21.11.2020.
//

import FirebladeECS
import Library

final class MotionControlSystem {
    private let isKeyDown: (Int32) -> Bool
    private let motionControls: Family3<MotionControls, Position, Motion>

    init(isKeyDown: @escaping (Int32) -> Bool, nexus: Nexus) {
        self.isKeyDown = isKeyDown
        motionControls = nexus.family(requiresAll: MotionControls.self, Position.self, Motion.self)
    }

    func update(time: Double) {
        for (control, position, motion) in motionControls {
            if isKeyDown(control.left) {
                position.rotation -= control.rotationRate * time
            }

            if isKeyDown(control.right) {
                position.rotation += control.rotationRate * time
            }

            if isKeyDown(control.accelerate) {
                motion.velocity.x += cos(position.rotation) * control.accelerationRate * time
                motion.velocity.y += sin(position.rotation) * control.accelerationRate * time
            }
        }
    }
}
