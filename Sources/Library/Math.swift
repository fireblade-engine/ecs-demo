//
//  Math.swift
//
//
//  Created by Igor Kravchenko on 29.10.2020.
//

import FirebladeMath

// swiftlint:disable prefixed_toplevel_constant
public let pow: (Double, Double) -> Double = FirebladeMath.pow
public let sqrt: (Double) -> Double = FirebladeMath.sqrt
public let cos: (Double) -> Double = FirebladeMath.cos
public let sin: (Double) -> Double = FirebladeMath.sin
public let ceil: (Double) -> Double = FirebladeMath.ceil
public let floor: (Double) -> Double = FirebladeMath.floor
// swiftlint:enable prefixed_toplevel_constant
public typealias Vector = Vec2d
public typealias Rect = FirebladeMath.Rect<Double>

public struct Matrix {
    var m11, m12, m13: Double
    var m21, m22, m23: Double
    var m31, m32, m33: Double
}

extension Matrix {
    // swiftlint:disable multiline_arguments
    public static var identity: Self {
        Self(m11: 1, m12: 0, m13: 0,
             m21: 0, m22: 1, m23: 0,
             m31: 0, m32: 0, m33: 1)
    }

    public init() {
        // identity matrix by default
        self = .identity
    }

    /// multiply two matrices together
    public static func * (lhs: Self, rhs: Self) -> Self {
        Self(
            //first row
            m11: (lhs.m11 * rhs.m11) + (lhs.m12 * rhs.m21) + (lhs.m13 * rhs.m31),
            m12: (lhs.m11 * rhs.m12) + (lhs.m12 * rhs.m22) + (lhs.m13 * rhs.m32),
            m13: (lhs.m11 * rhs.m13) + (lhs.m12 * rhs.m23) + (lhs.m13 * rhs.m33),
            //second
            m21: (lhs.m21 * rhs.m11) + (lhs.m22 * rhs.m21) + (lhs.m23 * rhs.m31),
            m22: (lhs.m21 * rhs.m12) + (lhs.m22 * rhs.m22) + (lhs.m23 * rhs.m32),
            m23: (lhs.m21 * rhs.m13) + (lhs.m22 * rhs.m23) + (lhs.m23 * rhs.m33),
            //third
            m31: (lhs.m31 * rhs.m11) + (lhs.m32 * rhs.m21) + (lhs.m33 * rhs.m31),
            m32: (lhs.m31 * rhs.m12) + (lhs.m32 * rhs.m22) + (lhs.m33 * rhs.m32),
            m33: (lhs.m31 * rhs.m13) + (lhs.m32 * rhs.m23) + (lhs.m33 * rhs.m33)
        )
    }

    public static func *= (lhs: inout Self, rhs: Self) {
        // swiftlint:disable shorthand_operator
        lhs = lhs * rhs
        // swiftlint:enable shorthand_operator
    }

    /// Applies a 2D transformation matrix to an array of Vectors
    /// - Parameter points: Inout array of points represented by Vector to be transformed
    public func transformVectors(_ points: inout [Vector]) {
        for idx in points.startIndex ..< points.endIndex {
            transformVector(&points[idx])
        }
    }

    /// Applies a 2D transformation matrix to Vector
    /// - Parameter point: Inout  point represented by Vector to be transformed
    @inline(__always)
    public func transformVector(_ point: inout Vector) {
        point = Vector(
            x: (m11 * point.x) + (m21 * point.y) + m31,
            y: (m12 * point.x) + (m22 * point.y) + m32
        )
    }

    /// Applies a 2D transformation matrix to Vector
    /// - Parameter point: point represented by Vector to be transformed
    /// - Returns: Vector with applied transformation
    public func transformedVector(_ point: Vector) -> Vector {
        Vector(
            x: (m11 * point.x) + (m21 * point.y) + m31,
            y: (m12 * point.x) + (m22 * point.y) + m32
        )
    }

    /// Applies translation  to current matrix
    /// - Parameter point: translation point for matrix
    public mutating func translate(by vec: Vector) {
        self *= Self(
            m11: 1, m12: 0, m13: 0,
            m21: 0, m22: 1, m23: 0,
            m31: vec.x, m32: vec.y, m33: 1
        )
    }

    /// Applies scaling to current matrix
    /// - Parameter point: scaling point for matrix
    public mutating func scale(by vec: Vector) {
        self *= Self(
            m11: vec.x, m12: 0, m13: 0,
            m21: 0, m22: vec.y, m23: 0,
            m31: 0, m32: 0, m33: 1
        )
    }

    /// Applies rotation  to current matrix
    /// - Parameter angle: angle by which matrix is rotated
    public mutating func rotate(_ angle: Double) {
        let sinValue = sin(angle)
        let cosValue = cos(angle)
        self *= Self(
            m11: cosValue, m12: sinValue, m13: 0,
            m21: -sinValue, m22: cosValue, m23: 0,
            m31: 0, m32: 0, m33: 1
        )
    }

    // swiftlint:enable multiline_arguments
}

extension Point where Value == Double {
    public var vector: Vector {
        Vector(x: x, y: y)
    }
}

extension Rect where Value == Double {
    public init(min: Vector, max: Vector) {
        self.init(x: min.x, y: min.y, width: max.x - min.x, height: max.y - min.y)
    }
}

extension Vector {
    public var point: Point<Double> {
        Point(self)
    }

    @inline(__always)
    public static func distanceSQ(_ pointA: Self, _ pointB: Self) -> Double {
        let dist = pointA - pointB
        return dist.x * dist.x + dist.y * dist.y
    }

    @inline(__always)
    public static func distance(_ pointA: Self, _ pointB: Self) -> Double {
        sqrt(distanceSQ(pointA, pointB))
    }
}
