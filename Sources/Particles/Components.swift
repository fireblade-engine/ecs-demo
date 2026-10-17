//
//  Components.swift
//  FirebladeECSDemo
//

import FirebladeECS
import FirebladeECSMacros

// `@Component` makes each class cloneable, serializable (snapshots), inspectable and
// default initializable, and registers it under a stable type name.

@Component
final class Name: @unchecked Sendable {
    var name: String = ""

    init(_ name: String) {
        self.name = name
    }
}

@Component
final class Position: @unchecked Sendable {
    var x: Int32 = 0
    var y: Int32 = 0

    init(x: Int32, y: Int32) {
        self.x = x
        self.y = y
    }
}

@Component
final class Color: @unchecked Sendable {
    var r: UInt8 = .random(in: 1...255)
    var g: UInt8 = .random(in: 1...255)
    var b: UInt8 = .random(in: 1...255)
}
