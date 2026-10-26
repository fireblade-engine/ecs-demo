//
//  WaitForStart.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import FirebladeECSMacros

@Component(excluding: [.serializable, .cloneable])  // holds live views or state machines
struct WaitForStart: @unchecked Sendable {
    var waitForStart: WaitForStartView
    var startGame: Bool = false

    init(waitForStart: WaitForStartView) {
        self.waitForStart = waitForStart
    }
}
