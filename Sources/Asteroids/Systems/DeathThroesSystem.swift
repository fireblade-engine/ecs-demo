//
//  DeathThroesSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 21.11.2020.
//

import FirebladeECS

final class DeathThroesSystem {
    private let creator: EntityCreator
    private let family: Family<DeathThroes>

    init(creator: EntityCreator, nexus: Nexus) {
        self.creator = creator
        family = nexus.family(requires: DeathThroes.self)
    }

    func update(time: Double) {
        family.forEach(writing: DeathThroes.self) { death in
            death.countdown -= time
        }
        // structural changes are not allowed inside forEach, destroy afterwards
        for (entity, death) in family.entityAndComponents where death.countdown <= 0 {
            creator.destroy(entity: entity)
        }
    }
}
