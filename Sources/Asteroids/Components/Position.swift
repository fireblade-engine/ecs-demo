//
//  Position.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import FirebladeECSMacros
import AsteroidsGameLibrary

@Component
final class Position: @unchecked Sendable {
    var position: Vector = .zero
    var rotation: Double = 0

    init(x: Double, y: Double, rotation: Double) {
        position = [x, y]
        self.rotation = rotation
    }
}
