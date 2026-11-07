//
//  Bullet.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import FirebladeECSMacros

@Component
struct Bullet {
    var lifeRemaining: Double = 0

    init(lifetime: Double) {
        lifeRemaining = lifetime
    }
}
