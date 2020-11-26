//
//  Hud.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS

final class Hud: Component {
    var view: HudView

    init(view: HudView) {
        self.view = view
    }
}
