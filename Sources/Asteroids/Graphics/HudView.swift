//
//  HudView.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 12.11.2020.
//

import AsteroidsGameLibrary

final class HudView: Renderable {
    private let score: Label
    private let lives: Label

    override init() {
        score = .init()
        score.position = Vector(x: 480, y: 5)
        lives = .init()
        lives.position = Vector(x: 0, y: 5)
        super.init()
        addChild(score)
        addChild(lives)
    }

    func setScore(_ value: Int) {
        score.text = "SCORE: \(value)"
    }

    func setLives(_ value: Int) {
        lives.text = "LIVES: \(value)"
    }

    func set(width: Double) {
        score.position.x = width - score.width
    }
}
