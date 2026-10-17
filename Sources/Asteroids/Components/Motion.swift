//
//  Motion.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import FirebladeECSMacros
import AsteroidsGameLibrary

@Component
final class Motion: @unchecked Sendable {
    var velocity: Vector = .zero
    var angularVelocity: Double = 0
    var damping: Double = 0

    init(velocityX: Double, velocityY: Double, angularVelocity: Double, damping: Double) {
        velocity = [velocityX, velocityY]
        self.angularVelocity = angularVelocity
        self.damping = damping
    }
}
