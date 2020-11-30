//
//  DeathThroes.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS

class DeathThroes: ComponentInitializable {
    var countdown: Double

    init(duration: Double) {
        countdown = duration
    }

    required init() {
        countdown = .zero
    }
}
