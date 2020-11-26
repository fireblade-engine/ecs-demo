//
//  BulletView.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 11.10.2020.
//

import Library

final class BulletView: Renderable {
    override init() {
        super.init()
        graphics.add(.addFilledRectangles([.init(x: -2, y: -2, width: 4, height: 4)]))
    }
}
