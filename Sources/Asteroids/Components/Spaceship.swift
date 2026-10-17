//
//  Spaceship.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 11.10.2020.
//

import FirebladeECS
import FirebladeECSMacros

@Component(excluding: [.serializable, .cloneable])  // holds live views or state machines
final class Spaceship: @unchecked Sendable {
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
