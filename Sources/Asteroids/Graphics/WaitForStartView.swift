//
//  WaitForStartView.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 13.11.2020.
//

import Library

final class WaitForStartView: Renderable {
    private let gameOver: Label
    private let clickToStart: Label
    var click = {}

    override init() {
        gameOver = Label()
        gameOver.text = "ASTEROIDS"
        gameOver.scale *= 2.5

        clickToStart = Label()
        clickToStart.text = "CLICK TO START"

        super.init()

        addChild(gameOver)
        addChild(clickToStart)

        handleEvent = { [weak self] event in
            if case .click = event {
                self?.click()
            }
        }
    }

    func setSize(width: Double, height: Double) {
        gameOver.position.x = (width - (gameOver.width * gameOver.scale.x)) * 0.5
        gameOver.position.y = (height - gameOver.height) * 0.35
        clickToStart.position.x = (width - clickToStart.width) * 0.5
        clickToStart.position.y = gameOver.position.y + 75
    }
}
