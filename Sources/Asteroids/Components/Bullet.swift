//
//  Bullet.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import FirebladeECSMacros

@Component
final class Bullet: @unchecked Sendable {
    var lifeRemaining: Double = 0

    init(lifetime: Double) {
        lifeRemaining = lifetime
    }
}
