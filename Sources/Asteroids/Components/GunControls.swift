//
//  GunControls.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS

final class GunControls: ComponentInitializable {
    var trigger: Int32

    init(trigger: Int32) {
        self.trigger = trigger
    }

    required init() {
        trigger = 0
    }
}
