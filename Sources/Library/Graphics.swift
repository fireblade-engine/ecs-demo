//
//  Graphics.swift
//
//
//  Created by Igor Kravchenko on 30.10.2020.
//

/// Used as drawing API for visual representation of shapes on the screen
public class Graphics {
    public private (set) var commands = [Command]()

    public init() {}

    @inline(__always)
    public func add(_ command: Command) {
        commands.append(command)
    }

    @inline(__always)
    public func add(commands: [Command]) {
        self.commands.append(contentsOf: commands)
    }

    public func clear(keepingCapacity: Bool) {
        commands.removeAll(keepingCapacity: keepingCapacity)
    }
}

extension Graphics {
    /// Specifies action to be interpreted by render engine into draw call(s)
    public enum Command {
        case addPath(Path)
        case addFilledRectangles([Rect])
    }
}

extension Graphics {
    /// Partially mimics UIBezierPath for presenting series of lines using convenient methods
    public struct Path {
        public private(set) var lines = [[Vector]]()

        public init() {}

        public mutating func move(to point: Vector) {
            if lines.isEmpty || lines[lines.count - 1].count > 1 {
                lines.append([point])
            } else if lines[lines.count - 1].isEmpty {
                lines[lines.count - 1].append(point)
            } else if lines[lines.count - 1].count == 1 {
                lines[lines.count - 1][0] = point
            } else {
                fatalError("unhandled case")
            }
        }

        public mutating func addLine(to point: Vector) {
            if lines.isEmpty {
                lines.append([.zero])
            }
            assert(!lines.isEmpty)
            assert(!lines[lines.count - 1].isEmpty)
            lines[lines.count - 1].append(point)
        }

        public mutating func addCurve(to anchor: Vector, controlPoint1: Vector, controlPoint2: Vector) {
            if lines.isEmpty {
                lines.append([.zero])
            } else if lines[lines.count - 1].isEmpty {
                lines.removeLast()
            }

            assert(!lines.isEmpty)
            let lastLine = lines[lines.count - 1]
            lines[lines.count - 1]
                .append(
                    contentsOf: buildCubicBezierLineSegments(
                        point0: lastLine[lastLine.count - 1],
                        point1: controlPoint1,
                        point2: controlPoint2,
                        point3: anchor
                    )
                )
        }

        public mutating func close() {
            guard let lastLine = lines.last else {
                return
            }

            guard !lastLine.isEmpty else {
                return
            }

            guard lastLine.count >= 2 else {
                return
            }

            addLine(to: lastLine[0])
        }

        private func cubicBezier(point0: Vector, point1: Vector, point2: Vector, point3: Vector, tValue: Double) -> Vector {
            Vector(
                x: pow(1 - tValue, 3) * point0.x + pow(1 - tValue, 2) * 3 * tValue * point1.x +
                    (1 - tValue) * 3 * tValue * tValue * point2.x +
                    tValue * tValue * tValue * point3.x,
                y: pow(1 - tValue, 3) * point0.y + pow(1 - tValue, 2) * 3 * tValue * point1.y +
                    (1 - tValue) * 3 * tValue * tValue * point2.y +
                    tValue * tValue * tValue * point3.y)
        }

        private func buildCubicBezierLineSegments(point0: Vector, point1: Vector, point2: Vector, point3: Vector) -> [Vector] {
            let count = tesselationSegments(for: approximateLength(controlPoints: [point0, point1, point2, point3]))
            return (0 ..< count).map { cubicBezier(point0: point0,
                                                   point1: point1,
                                                   point2: point2,
                                                   point3: point3,
                                                   tValue: Double($0) / Double(count - 1))
            }
        }

        private func tesselationSegments(for length: Double) -> Int {
            let noLessThan: Double = 10.0
            let segs = length / 30.0
            return Int(ceil(sqrt(segs * segs * 0.6 + noLessThan * noLessThan)))
        }

        private func approximateLength(controlPoints: [Vector]) -> Double {
            let allButLast = controlPoints.prefix(3)
            let diffs = zip(allButLast, 0...).map { elem, idx in
                controlPoints[idx + 1] - elem
            }

            return diffs.reduce(0.0) { prev, vec in prev + vec.length }
        }
    }
}

extension Graphics.Path: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: [Vector]...) {
        self.lines = elements
    }
}
