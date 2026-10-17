//
//  Components.swift
//  FirebladeECSDemo
//

import FirebladeECSMacros

// `@Component` makes each class cloneable, serializable (snapshots), inspectable and
// default initializable, and registers it under a stable type name.
// The explicit `Component` conformance is needed as long as the macro (FirebladeECS 1.4.1) doesn't list
// `Component` among its extension conformances; without it, files compiled before the macro expands
// fail with "type does not conform to protocol 'Component'".

@Component
final class Name: Component, @unchecked Sendable {
    var name: String = ""

    init(_ name: String) {
        self.name = name
    }
}

@Component
final class Position: Component, @unchecked Sendable {
    var x: Int32 = 0
    var y: Int32 = 0

    init(x: Int32, y: Int32) {
        self.x = x
        self.y = y
    }
}

@Component
final class Color: Component, @unchecked Sendable {
    var r: UInt8 = .random(in: 1...255)
    var g: UInt8 = .random(in: 1...255)
    var b: UInt8 = .random(in: 1...255)
}
