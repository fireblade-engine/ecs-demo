//
//  Event.swift
//
//
//  Created by Igor Kravchenko on 14.11.2020.
//

/// Event used by Renderable to detect user interaction
public enum Event {
    case mouseDown(position: Vector, time: Double)
    case mouseUp(position: Vector, time: Double)
    case click(Vector)
}
