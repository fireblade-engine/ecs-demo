//
//  Gun.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECSMacros
import AsteroidsGameLibrary

@Component
final class Gun: Component, @unchecked Sendable {
    var shooting: Bool = false
    var offsetFromParent: Vector = .zero
    var timeSinceLastShot: Double = 0
    var minimumShotInterval: Double = 0
    var bulletLifetime: Double = 0

    init(offsetX: Double, offsetY: Double, minimumShotInterval: Double, bulletLifetime: Double) {
        offsetFromParent = [offsetX, offsetY]
        self.minimumShotInterval = minimumShotInterval
        self.bulletLifetime = bulletLifetime
    }
}
