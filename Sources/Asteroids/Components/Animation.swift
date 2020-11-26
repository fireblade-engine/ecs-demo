//
//  Animation.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS

final class Animation: ComponentInitializable {
    var animation: Animatable

    init(animation: Animatable) {
        self.animation = animation
    }

    // swiftlint:disable unavailable_function
    required init() {
        fatalError("use init(animation:) instead")
    }
    // swiftlint:enable unavailable_function
}
