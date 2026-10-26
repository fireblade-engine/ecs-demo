//
//  DeathThroes.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import FirebladeECSMacros

@Component
struct DeathThroes {
    var countdown: Double = 0

    init(duration: Double) {
        countdown = duration
    }
}
