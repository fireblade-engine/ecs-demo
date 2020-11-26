//
//  AudioSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import Dispatch
import FirebladeECS
import SDL2

class AudioSystem {
    private let queue = DispatchQueue(label: "asteroids.audio",
                                      qos: .userInteractive,
                                      attributes: .concurrent,
                                      autoreleaseFrequency: .workItem,
                                      target: .none)
    private let family: Family1<Audio>

    init(nexus: Nexus) {
        family = nexus.family(requires: Audio.self)
    }

    func update() {
        family.forEach { audio in
            audio.toPlay.forEach { sound in
                queue.async {
                    self.play(sound: sound)
                }
            }
            audio.toPlay.removeAll(keepingCapacity: true)
        }
    }

    func play(sound: Audio.Sound) {
        guard let path = bundleResourcesPath()?.appendingPathComponent(sound.rawValue).path else {
            assertionFailure("unable to find path for '\(sound.rawValue)' resource")
            return
        }
        assert(sound.rawValue.hasSuffix(".wav"))
        var specIn = SDL_AudioSpec()
        var specOut = SDL_AudioSpec()
        let audio = SDL_OpenAudioDevice(.none, 0, &specIn, &specOut, 0)
        guard audio > 0, let ops = SDL_RWFromFile(path, "rb") else {
            print(String(cString: SDL_GetError()))
            return
        }

        var wavLength: Uint32 = 0
        var wavBuffer: UnsafeMutablePointer<Uint8>?
        if SDL_LoadWAV_RW(
            ops,
            1,
            &specIn,
            &wavBuffer,
            &wavLength
        ) == nil {
            print(String(cString: SDL_GetError()))
        }

        SDL_QueueAudio(audio, wavBuffer, wavLength)
        SDL_PauseAudioDevice(audio, 0)

        while SDL_GetQueuedAudioSize(audio) > 0 {
            SDL_Delay(1000)
        }

        SDL_CloseAudioDevice(audio)
        SDL_FreeWAV(wavBuffer)
    }
}
