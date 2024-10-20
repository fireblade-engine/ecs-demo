//
// Created by pcbeard on 9/17/2021.
//

import Foundation
@_exported import SDL

protocol FlagsValue: RawRepresentable {
}

extension FlagsValue where RawValue: BinaryInteger {
    #if os(Windows)
    typealias Value = UInt32
    #else
    typealias Value = UInt32
    #endif

    /// Returns platform specific flags values, which doesn't always match RawValue.
    var flagsValue: Value {
        Value(rawValue)
    }
}

/// Option set for the flags passed to `SDL_Init()`.
public struct SDLK_SubsytemFlags: OptionSet, FlagsValue {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let audio = Self(rawValue: SDL_INIT_AUDIO)
    public static let events = Self(rawValue: SDL_INIT_EVENTS)
    public static let gameController = Self(rawValue: SDL_INIT_GAMECONTROLLER)
    public static let haptic = Self(rawValue: SDL_INIT_HAPTIC)
    public static let joystick = Self(rawValue: SDL_INIT_JOYSTICK)
    public static let timer = Self(rawValue: SDL_INIT_TIMER)
    public static let video = Self(rawValue: SDL_INIT_VIDEO)
    #if !os(Linux)
    public static let sensor = Self(rawValue: SDL_INIT_SENSOR)
    #endif
}

/**
 * Wrapper for `SDL_Init()` that converts subsystem flags and calls fatalError() on failure.
 * Calls atexit(SDL_Quit) as a convenience, if successful.
 * - Parameter subsystems: all subsystems to initialize option set
 * - Returns: true if successful
 */
public func SDL_Init(subsystems: SDLK_SubsytemFlags) -> Bool {
    let rv = SDL_Init(subsystems.rawValue)
    guard rv == 0 else { return false }
    atexit(SDL_Quit)
    return true
}

extension SDL_WindowFlags: OptionSet, FlagsValue {
    public static let fullScreen = SDL_WINDOW_FULLSCREEN
    public static let fullScreenDesktop = SDL_WINDOW_FULLSCREEN_DESKTOP
    public static let borderless = SDL_WINDOW_BORDERLESS
    public static let hidden = SDL_WINDOW_HIDDEN
    public static let resizable = SDL_WINDOW_RESIZABLE
    public static let shown = SDL_WINDOW_SHOWN
    public static let allowHighDPI = SDL_WINDOW_ALLOW_HIGHDPI

    public static let openGL = SDL_WINDOW_OPENGL
    public static let vulkan = SDL_WINDOW_VULKAN
    #if os(macOS) || os(iOS) || os(tvOS)
    public static let metal = SDL_WINDOW_METAL
    #endif
}

public func SDL_CreateWindow(_ name: String, _ x: Int32, _ y: Int32, _ w: Int32, _ h: Int32, _ flags: SDL_WindowFlags)
-> OpaquePointer! {
    SDL_CreateWindow(name, x, y, w, h, flags.flagsValue)
}

extension SDL_RendererFlags: OptionSet, FlagsValue {
    public static let software = SDL_RENDERER_SOFTWARE              /**< The renderer is a software fallback */
    public static let accelerated = SDL_RENDERER_ACCELERATED        /**< The renderer uses hardware acceleration */
    public static let presentVSync = SDL_RENDERER_PRESENTVSYNC      /**< Present is synchronized with the refresh rate */
    public static let targetTexture = SDL_RENDERER_TARGETTEXTURE    /**< The renderer supports rendering to texture */
}

public func SDL_CreateRenderer(_ window: OpaquePointer!, _ index: Int32, _ flags: SDL_RendererFlags) -> OpaquePointer! {
    SDL_CreateRenderer(window, index, flags.flagsValue)
}

#if os(Windows)
public typealias SDLK_RawValue = Int32
#else
public typealias SDLK_RawValue = UInt32
#endif

extension SDL_Event {
    @inlinable public var eventType: SDL_EventType {
        SDL_EventType(rawValue: SDLK_RawValue(self.type))
    }

    @inlinable public mutating func poll() -> SDL_EventType? {
        SDL_PollEvent(&self) == 1 ? self.eventType : nil
    }

    public var keyCode: SDL_KeyCode {
        SDL_KeyCode(SDLK_RawValue(self.key.keysym.sym))
    }

    public var keyRepeat: Bool {
        self.key.repeat != 0
    }

    public var keyName: String {
        String(cString: SDL_GetKeyName(self.key.keysym.sym))
    }

    public var controllerAxis: SDL_GameControllerAxis {
        self.eventType == SDL_CONTROLLERAXISMOTION ?
            SDL_GameControllerAxis(rawValue: Int32(self.caxis.axis)) :
            SDL_CONTROLLER_AXIS_INVALID
    }

    public var controllerButton: SDL_GameControllerButton {
        let type = self.eventType
        return (type == SDL_CONTROLLERBUTTONDOWN || type == SDL_CONTROLLERBUTTONUP) ?
            SDL_GameControllerButton(rawValue: Int32(self.cbutton.button)) :
            SDL_CONTROLLER_BUTTON_INVALID
    }

    public var windowEvent: SDL_WindowEventID {
        self.eventType == SDL_WINDOWEVENT ?
            SDL_WindowEventID(rawValue: SDLK_RawValue(self.window.event)) :
            SDL_WINDOWEVENT_NONE
    }
}

extension SDL_KeyCode {
    
    public static func ~= (lhs: Int, rhs: SDL_KeyCode) -> Bool {
        return lhs == rhs
    }
    
    public static func ~= (lhs: SDL_KeyCode, rhs: Int) -> Bool {
        return lhs == rhs
    }

    public static func ==(lhs: Int, rhs: SDL_KeyCode) -> Bool {
        return SDL_KeyCode(UInt32(lhs)) == rhs
    }

    public static func ==(lhs: SDL_KeyCode, rhs: Int) -> Bool {
        return lhs == SDL_KeyCode(UInt32(rhs))
    }
}
