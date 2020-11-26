//
//  AsteroidView.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.10.2020.
//

import Library

final class AsteroidView: Renderable {
    init(radius: Double) {
        super.init()
        var points = [Vector(x: radius, y: 0)]
        var angle = 0.0
        while angle < .pi * 2 {
            let length = .random(in: 0.75 ... 1.0) * radius
            let posX = cos(angle) * length
            let posY = sin(angle) * length
            points.append(.init(x: posX, y: posY))
            angle += .random(in: 0 ..< 0.5)
        }
        var path: Graphics.Path = [points]
        path.close()
        graphics.add(.addPath(path))
    }
}
