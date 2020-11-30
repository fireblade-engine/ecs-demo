//
//  WaitForStart.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS

final class WaitForStart: Component {
    var waitForStart: WaitForStartView
    var startGame: Bool = false

    init(waitForStart: WaitForStartView) {
        self.waitForStart = waitForStart
        waitForStart.click = { [weak self] in
            self?.startGame = true
        }
    }
}
