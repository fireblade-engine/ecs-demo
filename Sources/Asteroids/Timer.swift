//
//  Timer.swift
//  FirebladeECS
//
//  Created by Christian Treffs on 28.10.17.
//

import SDL2

public struct Timer {
    private let countPerSecond : UInt64
    private var startTime: UInt64 = 0
    private var stopTime: UInt64 = 0
    
    public init() {
        countPerSecond = SDL_GetPerformanceFrequency()
    }
    
    public mutating func start() {
        startTime = SDL_GetPerformanceCounter()
    }
    
    public mutating func stop() {
        stopTime = SDL_GetPerformanceCounter()
    }
    
    public mutating func reset() {
        startTime = 0
        stopTime = 0
    }
    
    public var nanoSeconds: UInt64 {
        return ((stopTime - startTime) * 1_000_000_000) / countPerSecond
    }
    
    public var microSeconds: Double {
        return Double((stopTime - startTime) * 1_000_000) / Double(countPerSecond)
    }
    
    public var milliSeconds: Double {
        return Double((stopTime - startTime) * 1_000) / Double(countPerSecond)
    }
    
    public var seconds: Double {
        return Double(stopTime - startTime) / Double(countPerSecond)
    }
}
