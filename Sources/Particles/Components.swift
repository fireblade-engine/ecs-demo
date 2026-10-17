//
//  Components.swift
//  FirebladeECSDemo
//

import FirebladeECSMacros

// `@Component` makes each class cloneable, serializable (snapshots), inspectable and
// default initializable, and registers it under a stable type name.
// The explicit `Component` conformance works around a compiler bug (swiftlang/swift#92390): the macro of
// FirebladeECS 1.4.1 only implies `Component`, and the compiler loses implied conformances of macro-generated
// extensions when another file looks up a member of the type first (fireblade-engine/ecs#154).

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
