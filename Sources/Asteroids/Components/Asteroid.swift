//
//  Asteroid.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS

final class Asteroid: Component {
    let fsm: EntityStateMachine<State>

    init(fsm: EntityStateMachine<State>) {
        self.fsm = fsm
    }
}

extension Asteroid {
    enum State: String {
        case alive, destroyed
    }
}
