//
//  Bullet.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECSMacros

@Component
final class Bullet: Component, @unchecked Sendable {
    var lifeRemaining: Double = 0

    init(lifetime: Double) {
        lifeRemaining = lifetime
    }
}
