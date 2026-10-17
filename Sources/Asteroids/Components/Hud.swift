//
//  Hud.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECSMacros

@Component(excluding: [.serializable, .cloneable])  // holds live views or state machines
final class Hud: Component, @unchecked Sendable {
    var view: HudView

    init(view: HudView) {
        self.view = view
    }
}
