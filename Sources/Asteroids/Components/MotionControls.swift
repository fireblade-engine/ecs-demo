//
//  MotionControls.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import Library

final class MotionControls: ComponentInitializable {
    var left: Int32
    var right: Int32
    var accelerate: Int32

    var accelerationRate: Double
    var rotationRate: Double

    init(left: Int32, right: Int32, accelerate: Int32, accelerationRate: Double, rotationRate: Double) {
        self.left = left
        self.right = right
        self.accelerate = accelerate
        self.accelerationRate = accelerationRate
        self.rotationRate = rotationRate
    }

    required init() {
        left = 0
        right = 0
        accelerate = 0
        accelerationRate = 0
        rotationRate = 0
    }
}
