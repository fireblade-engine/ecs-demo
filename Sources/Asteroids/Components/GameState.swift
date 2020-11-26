//
//  GameState.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS

final class GameState: Component {
    var lives = 0
    var level = 0
    var hits = 0
    var playing = false

    func setForStart() {
        lives = 3
        level = 0
        hits = 0
        playing = true
    }
}
