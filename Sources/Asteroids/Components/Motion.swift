//
//  Motion.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import Library

final class Motion: ComponentInitializable {
    var velocity: Vector
    var angularVelocity: Double
    var damping: Double

    init(velocityX: Double, velocityY: Double, angularVelocity: Double, damping: Double) {
        velocity = [velocityX, velocityY]
        self.angularVelocity = angularVelocity
        self.damping = damping
    }

    required init() {
        velocity = .zero
        angularVelocity = .zero
        damping = .zero
    }
}
