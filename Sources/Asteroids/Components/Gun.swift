//
//  Gun.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import Library

final class Gun: ComponentInitializable {
    var shooting = false
    var offsetFromParent: Vector
    var timeSinceLastShot = 0.0
    var minimumShotInterval = 0.0
    var bulletLifetime = 0.0

    init(offsetX: Double, offsetY: Double, minimumShotInterval: Double, bulletLifetime: Double) {
        offsetFromParent = [offsetX, offsetY]
        self.minimumShotInterval = minimumShotInterval
        self.bulletLifetime = bulletLifetime
    }

    required init() {
        shooting = false
        offsetFromParent = []
        timeSinceLastShot = 0
        minimumShotInterval = 0
        bulletLifetime = 0
    }
}
