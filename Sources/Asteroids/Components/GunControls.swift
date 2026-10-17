//
//  GunControls.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECSMacros

@Component
final class GunControls: Component, @unchecked Sendable {
    var trigger: Int32 = 0

    init(trigger: Int32) {
        self.trigger = trigger
    }
}
