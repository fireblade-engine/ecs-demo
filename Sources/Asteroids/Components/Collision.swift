//
//  Collision.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS

final class Collision: ComponentInitializable {
    var radius: Double

    init(radius: Double) {
        self.radius = radius
    }

    required init() {
        radius = 0
    }
}
