//
//  SpaceshipDeathView.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 19.10.2020.
//

import AsteroidsGameLibrary

class SpaceshipDeathView: Renderable {
    private let shape1 = Renderable()
    private let shape2 = Renderable()
    private let vel1 = Vector(x: .random(in: -5 ... 5), y: .random(in: 10 ... 20))
    private let vel2 = Vector(x: .random(in: -5 ... 5), y: -(.random(in: 10 ... 20)))
    private let rot1: Double = .random(in: -150 ... 150) * .pi / 180
    private let rot2: Double = .random(in: -150 ... 150) * .pi / 180

    override init() {
        shape1.graphics.add(
            .addPath(
                [[
                    .init(x: 10, y: 0),
                    .init(x: -7, y: 7),
                    .init(x: -4, y: 0),
                    .init(x: 10, y: 0)
                ]]
            )
        )

        super.init()

        addChild(shape1)
        shape2.graphics.add(
            .addPath(
                [[
                    .init(x: 10, y: 0),
                    .init(x: -7, y: -7),
                    .init(x: -4, y: 0),
                    .init(x: 10, y: 0)
                ]]
            ))
        addChild(shape2)
    }
}

extension SpaceshipDeathView: Animatable {
    func animate(time: Double) {
        shape1.position.x += vel1.x * time
        shape1.position.y += vel1.y * time
        shape1.rotation += rot1 * time
        shape2.position.x += vel2.x * time
        shape2.position.y += vel2.y * time
        shape2.rotation += rot2 * time
    }
}
