//
//  AnimationSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS

final class AnimationSystem {
    private let family: Family<Animation>

    init(nexus: Nexus) {
        family = nexus.family(requires: Animation.self)
    }

    func update(time: Double) {
        family.forEach(reading: Animation.self) { animation in
            animation.animation.animate(time: time)
        }
    }
}
