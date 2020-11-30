//
//  Bullet.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS

final class Bullet: ComponentInitializable {
    var lifeRemaining: Double

    init(lifetime: Double) {
        lifeRemaining = lifetime
    }

    required init() {
        lifeRemaining = 0
    }
}
