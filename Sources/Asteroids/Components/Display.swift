//
//  Display.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 17.10.2020.
//

import FirebladeECSMacros
import AsteroidsGameLibrary

@Component(excluding: [.serializable, .cloneable])  // holds live views or state machines
final class Display: Component, @unchecked Sendable {
    var renderable: Renderable

    init(renderable: Renderable) {
        self.renderable = renderable
    }

    init() {
        renderable = .init()
    }
}
