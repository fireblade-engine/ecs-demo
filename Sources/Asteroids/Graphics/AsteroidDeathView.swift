//
//  AsteroidDeathView.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 23.10.2020.
//

import AsteroidsGameLibrary

final class AsteroidDeathView: Renderable, Animatable {
    static let numDots = 8
    private var dots: [Dot]

    init(radius: Double) {
        dots = []
        super.init()
        for _ in 0 ..< Self.numDots {
            let dot = Dot(maxDistance: radius)
            addChild(dot.image)
            dots.append(dot)
        }
    }

    func animate(time: Double) {
        for dot in dots {
            dot.image.position.x += dot.velocity.x * time
            dot.image.position.y += dot.velocity.y * time
        }
    }
}

extension AsteroidDeathView {
    private final class Dot: Renderable {
        var velocity: Vector
        var image: Renderable

        init(maxDistance: Double) {
            image = .init()
            image.graphics.add(.addFilledRectangles([.init(x: -1, y: -1, width: 2, height: 2)]))
            let angle = Double.random(in: 0 ... 2 * .pi)
            let distance = Double.random(in: 0 ... maxDistance)
            image.position.x = cos(angle) * distance
            image.position.y = sin(angle) * distance
            let speed = Double.random(in: 10 ... 20)
            velocity = .init(x: cos(angle) * speed, y: sin(angle) * speed)
        }
    }
}
