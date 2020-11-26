//
//  GunControlSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 21.11.2020.
//

import FirebladeECS

final class GunControlSystem {
    private let isKeyDown: (Int32) -> Bool
    private let creator: EntityCreator
    private let gunControllsFamily: Family4<Gun, GunControls, Position, Audio>

    init(isKeyDown: @escaping (Int32) -> Bool, creator: EntityCreator, nexus: Nexus) {
        self.isKeyDown = isKeyDown
        self.creator = creator
        gunControllsFamily = nexus.family(requiresAll: Gun.self, GunControls.self, Position.self, Audio.self)
    }

    func update(time: Double) {
        for (gun, controls, position, audio) in gunControllsFamily {
            gun.shooting = isKeyDown(controls.trigger)
            gun.timeSinceLastShot += time
            if gun.shooting && gun.timeSinceLastShot >= gun.minimumShotInterval {
                creator.createBullet(gun: gun, parentPosition: position)
                audio.play(sound: .shootGun)
                gun.timeSinceLastShot = 0
            }
        }
    }
}
