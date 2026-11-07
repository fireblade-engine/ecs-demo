//
//  Audio.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import FirebladeECSMacros

@Component
struct Audio {
    enum Sound: String, CaseIterable, Codable {
        case explodeAsteroid = "asteroid.wav"
        case explodeShip = "ship.wav"
        case shootGun = "shoot.wav"
    }

    /// Sounds queued for the next audio system update; transient, so not serialized.
    @ComponentIgnored var toPlay: [Sound] = []

    mutating func play(sound: Sound) {
        toPlay.append(sound)
    }
}
