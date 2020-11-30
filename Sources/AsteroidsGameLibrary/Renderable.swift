//
//  Renderable.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 17.10.2020.
//

open class Renderable {
    public var position = Vector.zero
    public var rotation = 0.0
    public var scale = Vector.one

    public private (set) var children = [Renderable]()
    public private (set) weak var parent: Renderable?
    public var graphics = Graphics()
    public var handleEvent: ((Event) -> Void)?

    public init() {}

    public func addChild(_ child: Renderable) {
        child.parent?.removeChild(child)
        children.append(child)
        child.parent = self
    }

    public func removeChild(_ child: Renderable) {
        guard child.parent === self else {
            return
        }
        guard let idx = children.firstIndex(where: { $0 === child }) else {
            return
        }
        child.parent = nil
        children.remove(at: idx)
    }
}
