//
//  BulletAgeSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 20.11.2020.
//

import FirebladeECS

final class BulletAgeSystem {
    private let creator: EntityCreator
    private let family: Family1<Bullet>

    init(creator: EntityCreator, nexus: Nexus) {
        self.creator = creator
        family = nexus.family(requires: Bullet.self)
    }

    func update(time: Double) {
        for (entity, bullet) in family.entityAndComponents {
            bullet.lifeRemaining -= time
            if bullet.lifeRemaining <= 0 {
                creator.destroy(entity: entity)
            }
        }
    }
}
