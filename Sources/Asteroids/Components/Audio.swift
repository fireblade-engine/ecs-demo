//
//  Audio.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS

final class Audio: Component {
    var toPlay = [Sound]()

    @inline(__always)
    func play(sound: Sound) {
        toPlay.append(sound)
    }
}

extension Audio {
    enum Sound: String {
        case explodeAsteroid = "asteroid.wav"
        case explodeShip = "ship.wav"
        case shootGun = "shoot.wav"
    }
}
