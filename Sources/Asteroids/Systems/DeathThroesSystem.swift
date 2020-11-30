//
//  DeathThroesSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 21.11.2020.
//

import FirebladeECS

final class DeathThroesSystem {
    private let creator: EntityCreator
    private let family: Family<Requires1<DeathThroes>>

    init(creator: EntityCreator, nexus: Nexus) {
        self.creator = creator
        family = nexus.family(requires: DeathThroes.self)
    }

    func update(time: Double) {
        for (entity, death) in family.entityAndComponents {
            death.countdown -= time
            if death.countdown <= 0 {
                creator.destroy(entity: entity)
            }
        }
    }
}
