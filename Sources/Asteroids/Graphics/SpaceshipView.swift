//
//  SpaceshipView.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 17.10.2020.
//

import AsteroidsGameLibrary

final class SpaceshipView: Renderable {
    override init() {
        super.init()

        var path: Graphics.Path = [[
            .init(x: 10, y: 0),
            .init(x: -7, y: 7),
            .init(x: -4, y: 0),
            .init(x: -7, y: -7)
        ]]
        path.close()

        graphics.add(
            commands: [
                .addPath(path)
            ]
        )
    }
}
