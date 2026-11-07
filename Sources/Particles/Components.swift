//
//  Components.swift
//  FirebladeECSDemo
//

import FirebladeECS
import FirebladeECSMacros

// `@Component` makes each class cloneable, serializable (snapshots), inspectable and
// default initializable, and registers it under a stable type name.

@Component
struct Name {
    var name: String = ""

    init(_ name: String) {
        self.name = name
    }
}

@Component
struct Position {
    var x: Int32 = 0
    var y: Int32 = 0

    init(x: Int32, y: Int32) {
        self.x = x
        self.y = y
    }
}

@Component
struct Color {
    var r: UInt8 = .random(in: 1...255)
    var g: UInt8 = .random(in: 1...255)
    var b: UInt8 = .random(in: 1...255)
}
