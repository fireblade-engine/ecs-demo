//
//  DeathThroes.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import FirebladeECSMacros

@Component
final class DeathThroes: @unchecked Sendable {
    var countdown: Double = 0

    init(duration: Double) {
        countdown = duration
    }
}
