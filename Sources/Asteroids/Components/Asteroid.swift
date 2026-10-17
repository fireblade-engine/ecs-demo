//
//  Asteroid.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECSMacros

@Component(excluding: [.serializable, .cloneable])  // holds live views or state machines
final class Asteroid: Component, @unchecked Sendable {
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
