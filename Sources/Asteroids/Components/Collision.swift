//
//  Collision.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import FirebladeECSMacros

@Component
final class Collision: @unchecked Sendable {
    var radius: Double = 0

    init(radius: Double) {
        self.radius = radius
    }
}
