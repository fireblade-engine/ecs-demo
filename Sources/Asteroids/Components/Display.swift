//
//  Display.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 17.10.2020.
//

import FirebladeECS
import AsteroidsGameLibrary

final class Display: ComponentInitializable {
    var renderable: Renderable

    init(renderable: Renderable) {
        self.renderable = renderable
    }

    required init() {
        renderable = .init()
    }
}
