//
//  MotionControls.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import AsteroidsGameLibrary

final class MotionControls: ComponentInitializable {
    var left: Set<Int32>
    var right: Set<Int32>
    var accelerate: Set<Int32>

    var accelerationRate: Double
    var rotationRate: Double

    init(left: Set<Int32>, right: Set<Int32>, accelerate: Set<Int32>, accelerationRate: Double, rotationRate: Double) {
        self.left = left
        self.right = right
        self.accelerate = accelerate
        self.accelerationRate = accelerationRate
        self.rotationRate = rotationRate
    }

    required init() {
        left = []
        right = []
        accelerate = []
        accelerationRate = 0
        rotationRate = 0
    }
}
