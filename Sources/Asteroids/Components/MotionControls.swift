//
//  MotionControls.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import FirebladeECSMacros
import AsteroidsGameLibrary

@Component
final class MotionControls: @unchecked Sendable {
    var left: Set<Int32> = []
    var right: Set<Int32> = []
    var accelerate: Set<Int32> = []
    var accelerationRate: Double = 0
    var rotationRate: Double = 0

    init(left: Set<Int32>, right: Set<Int32>, accelerate: Set<Int32>, accelerationRate: Double, rotationRate: Double) {
        self.left = left
        self.right = right
        self.accelerate = accelerate
        self.accelerationRate = accelerationRate
        self.rotationRate = rotationRate
    }
}
