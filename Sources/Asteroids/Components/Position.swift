//
//  Position.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import AsteroidsGameLibrary

final class Position: Component {
    var position: Vector
    var rotation: Double

    init(x: Double, y: Double, rotation: Double) {
        position = [x, y]
        self.rotation = rotation
    }
}
