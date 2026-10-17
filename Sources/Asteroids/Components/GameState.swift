//
//  GameState.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECSMacros

@Component
final class GameState: Component, @unchecked Sendable {
    var lives: Int = 0
    var level: Int = 0
    var hits: Int = 0
    var playing: Bool = false

    func setForStart() {
        lives = 3
        level = 0
        hits = 0
        playing = true
    }
}
