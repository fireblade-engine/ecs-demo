//
//  AudioSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//  Modified by @pcbeard  on 29.9.2021.
//

import Dispatch
import FirebladeECS
import SDL2

/// In-memory copy of a sound file. Currently these remain loaded forever to avoid audio dropouts.
struct AudioData {
    var sound : Audio.Sound
    var spec : SDL_AudioSpec
    var buffer : UnsafeMutableRawPointer
    var length : Int
}

typealias MixBuffer = (count: Int, format: SDL_AudioFormat, pointer: UnsafeMutableRawPointer)

struct MixCallbackData {
    var player : MixingAudioPlayer
    var queue : DispatchQueue
    var buffers : [MixBuffer] = []
}

/// helper function to convert arrays or inout parameters into scoped pointers.
@inlinable public func withPointer<R, T1>(_ p1 : UnsafePointer<T1>,
                                          _ body: (UnsafePointer<T1>) throws -> R)
rethrows -> R {
    try body(p1)
}

@inlinable public func withMutablePointer<R, T1>(_ p1 : UnsafeMutablePointer<T1>,
                                                 _ body: (UnsafeMutablePointer<T1>) throws -> R)
rethrows -> R {
    try body(p1)
}

typealias MutableSamplePtr = UnsafeMutablePointer<UInt8>
typealias SamplePtr = UnsafePointer<UInt8>
typealias Mixer = (MutableSamplePtr, SamplePtr, SDL_AudioFormat, Int) -> Void

func mixAudioBuffers(_ data: inout MixCallbackData,
                     _ audioStream: MutableSamplePtr,
                     _ length: Int) -> Bool
{
    var finished = false
    func mixBuffer(_ buffer : inout MixBuffer, mixer: Mixer) {
        let count = min(length, buffer.count)
        if count == 0 {
            // This buffer is empty. Schedule buffer removal.
            finished = true
        } else {
            // mix the next range of samples.
            let bufferPointer = UnsafeRawPointer(buffer.pointer).assumingMemoryBound(to: UInt8.self)
            mixer(audioStream, bufferPointer, buffer.format, count)
            buffer.pointer = buffer.pointer.advanced(by: count)
            buffer.count -= count
        }
    }
    let bufferCount = data.buffers.count
    withMutablePointer(&data.buffers) { buffers in
        if bufferCount == 1 {
            // special case single buffer case, no need to mix.
            mixBuffer(&buffers[0]) {
                memcpy($0, $1, $3)
                // but need to clear remainder.
                let count = $3, remaining = length - count
                if remaining > 0 {
                    memset(UnsafeMutableRawPointer(audioStream).advanced(by: count), 0, remaining)
                }
            }
        } else {
            // fill stream with silence before mixing.
            memset(audioStream, 0, length)
            for i in 0..<bufferCount {
                mixBuffer(&buffers[i]) {
                    SDL_MixAudioFormat($0, $1, $2, UInt32($3), SDL_MIX_MAXVOLUME)
                }
            }
        }
    }
    return finished
}

func mixAudioCallback(userDataOrNil : UnsafeMutableRawPointer?,
                      audioStreamOrNil: UnsafeMutablePointer<UInt8>?,
                      length : Int32)
{
    // validate that pointers aren't nil
    if let userData = userDataOrNil, let audioStream = audioStreamOrNil {
        let data = userData.assumingMemoryBound(to: MixCallbackData.self)
        let finished = mixAudioBuffers(&data.pointee, audioStream, Int(length))
        if finished {
            data.pointee.queue.async {
                let player = data.pointee.player
                player.buffersFinished()
            }
        }
    }
}

class MixingAudioPlayer {
    let data : UnsafeMutablePointer<MixCallbackData>
    var device : SDL_AudioDeviceID
    var playing = false
    
    init(_ queue : DispatchQueue, _ audioSpec : SDL_AudioSpec) {
        data = UnsafeMutablePointer<MixCallbackData>.allocate(capacity: 1)
        
        var want = audioSpec
        want.samples = 512
        want.callback = mixAudioCallback
        want.userdata = UnsafeMutableRawPointer(data)
        var have = SDL_AudioSpec()
        device = SDL_OpenAudioDevice(nil, 0, &want, &have, 0)
        if device > 0 {
            data.initialize(to: MixCallbackData(player: self, queue: queue))
        }
    }
    
    deinit {
        if device > 0 {
            SDL_CloseAudioDevice(device)
        }
        // For this to be safe, we need a guarantee that the callback will never be called
        // again. Testing shows that closing the audio device isn't a strong enough guarantee,
        // so the `CallbackData` blocks are leaked deliberately.
        // data.deallocate()
    }
    
    /// Prepare the player to play audio data. In theory, this could be called
    /// at any moment, to interrupt the currently playing sound, but in practice
    /// that will cause clicks, so this is only ever called when the audio
    /// device is paused.
    /// - Parameter audioData:
    func prepare(_ audioData : AudioData) {
        SDL_LockAudioDevice(device)
        data.pointee.buffers.append(
            (count: audioData.length,
             format: audioData.spec.format,
             pointer: audioData.buffer))
        SDL_UnlockAudioDevice(device)
    }
    
    func buffersFinished() {
        SDL_LockAudioDevice(device)
        data.pointee.buffers = data.pointee.buffers.filter { $0.count > 0 }
        SDL_UnlockAudioDevice(device)
        if data.pointee.buffers.isEmpty {
            self.pause()
        }
    }
    
    func start() {
        if !playing {
            SDL_PauseAudioDevice(device, 0)
            playing = true
        }
    }
    
    func pause() {
        if playing {
            SDL_PauseAudioDevice(device, 1)
            playing = false
        }
    }
    
    func dump() {
        Swift.dump(data.pointee, maxDepth: 1)
    }
}

class AudioSystem {
    private let queue = DispatchQueue(label: "asteroids.audio",
                                      qos: .userInteractive,
                                      attributes: .concurrent,
                                      autoreleaseFrequency: .workItem,
                                      target: .none)
    private let family: Family1<Audio>

    init(nexus: Nexus) {
        family = nexus.family(requires: Audio.self)
        queue.async {
            // preload all known sounds.
            Audio.Sound.allCases.forEach { sound in
                self.prepare(sound: sound)
            }
        }
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

    private var audioDataCache: [Audio.Sound : AudioData] = [:]

    func fetchAudioData(_ sound: Audio.Sound) -> AudioData? {
        if let audioData = audioDataCache[sound] {
            return audioData
        }
        if let path = bundleResourcesPath()?.appendingPathComponent(sound.rawValue).path {
            if let ops = SDL_RWFromFile(path, "rb") {
                var spec = SDL_AudioSpec()
                var length: UInt32 = 0
                var bufferOrNil: UnsafeMutablePointer<UInt8>?
                if SDL_LoadWAV_RW(ops, 1, &spec, &bufferOrNil, &length) != nil, let buffer = bufferOrNil  {
                    let audioData = AudioData(sound: sound, spec: spec, buffer: UnsafeMutableRawPointer(buffer), length: Int(length))
                    audioDataCache[sound] = audioData
                    return audioData
                }
            }
        }
        if let error = SDL_GetError() {
            print(String(cString: error))
        }
        return nil
    }

    private var mixingPlayer : MixingAudioPlayer?
    
    func getMixingPlayer(_ audioSpec : SDL_AudioSpec) -> MixingAudioPlayer? {
        if let player = mixingPlayer {
            return player
        }
        let player = MixingAudioPlayer(queue, audioSpec)
        mixingPlayer = player
        return player
    }
    
    private func play(audio audioData : AudioData) {
        if let player = getMixingPlayer(audioData.spec) {
            player.prepare(audioData)
            player.start()
        }
    }

    private func prepare(audio audioData : AudioData) -> Bool {
        getMixingPlayer(audioData.spec) != nil
    }

    /**
     * Plays a sound asynchronously using an SDL sound device. Because closing audio devices
     * after playback seems to be so race-prone (causing crashes), this creates a single instance of
     * the class `MixAudioPlayer` which keeps the audio device paused when not in use
     * (to reduce CPU). The player allocates a an unsafe pointer to a `MixCallbackData` struct,
     * which is passed to the callback function `mixAudioCallback`, when the audio device needs
     * audio buffers to play. The `MixCallbackData` struct contains an array of audio buffers to be mixed.
     * When an audio buffer is fully consumed, `mixAudioBuffers()` returns true, and
     * `mixAudioCallback` calls `MixAudioPlayer.buffersFinished()` which removes
     * any buffers where `buffer.count == 0`.
     * - Parameter sound: an enum that specifies a known .wav file resource.
     */
    func play(sound: Audio.Sound) {
        assert(sound.rawValue.hasSuffix(".wav"))
        if let audioData = fetchAudioData(sound) {
            play(audio: audioData)
        }
    }
    
    /// Preloads audio data and starts the audio system so sounds will play immediately.
    @discardableResult func prepare(sound: Audio.Sound) -> Bool {
        if let audioData = fetchAudioData(sound) {
            return prepare(audio: audioData)
        }
        return false
    }
}
