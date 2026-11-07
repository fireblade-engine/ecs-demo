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
    private let gunControllsFamily: Family<Gun, GunControls, Position, Audio>

    init(isKeyDown: @escaping (Int32) -> Bool, creator: EntityCreator, nexus: Nexus) {
        self.isKeyDown = isKeyDown
        self.creator = creator
        gunControllsFamily = nexus.family(requiresAll: Gun.self, GunControls.self, Position.self, Audio.self)
    }

    func update(time: Double) {
        var shots: [(gun: Gun, parentPosition: Position)] = []
        gunControllsFamily.forEach(reading: GunControls.self, Position.self,
                                   writing: Gun.self, Audio.self) { controls, position, gun, audio in
            gun.shooting = isKeyDown(controls.trigger)
            gun.timeSinceLastShot += time
            if gun.shooting && gun.timeSinceLastShot >= gun.minimumShotInterval {
                shots.append((gun: gun, parentPosition: position))
                audio.play(sound: .shootGun)
                gun.timeSinceLastShot = 0
            }
        }
        // creating entities is a structural change, which is not allowed inside forEach
        for shot in shots {
            creator.createBullet(gun: shot.gun, parentPosition: shot.parentPosition)
        }
    }
}
