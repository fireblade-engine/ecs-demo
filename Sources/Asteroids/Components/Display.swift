//
//  Display.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 17.10.2020.
//

import FirebladeECS
import FirebladeECSMacros
import AsteroidsGameLibrary

@Component(excluding: [.serializable, .cloneable])  // holds live views or state machines
final class Display: @unchecked Sendable {
    var renderable: Renderable

    init(renderable: Renderable) {
        self.renderable = renderable
    }

    init() {
        renderable = .init()
    }
}
