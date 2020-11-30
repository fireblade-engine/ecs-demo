//
//  Spaceship.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 11.10.2020.
//

import FirebladeECS

final class Spaceship: Component {
    let fsm: EntityStateMachine<State>

    init(fsm: EntityStateMachine<State>) {
        self.fsm = fsm
    }
}

extension Spaceship {
    enum State: String {
        case playing, destoyed
    }
}
