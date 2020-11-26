//
//  Label.swift
//
//
//  Created by Igor Kravchenko on 09.11.2020.
//

/// Draws text on screen
open class Label: Renderable {
    private static let symbolScale = 0.015

    private static func calculateWidth(result: Double, rect: Rect) -> Double {
        max(result, rect.maxX)
    }

    private static func calculateHeight(result: Double, rect: Rect) -> Double {
        max(result, rect.maxY)
    }

    private var rects = [Rect]()

    public private (set) var width: Double = .zero
    public private (set) var height: Double = .zero

    public var text: String = "" {
        didSet {
            guard text.uppercased() != oldValue.uppercased() else {
                return
            }
            rects.removeAll(keepingCapacity: true)
            width = .zero
            height = .zero
            var origin = position
            var lastSymbol: Symbol?
            for char in text.uppercased() {
                let symbol = Self.symbols[char] ?? Self.symbols["?"].unsafelyUnwrapped
                if let last = lastSymbol {
                    origin.x += last.size.x
                }
                lastSymbol = symbol
                rects.append(contentsOf: symbol.offset(by: origin, scale: Self.symbolScale).rects)
            }
            width = rects.reduce(0, Self.calculateWidth)
            height = rects.reduce(0, Self.calculateHeight)
            graphics.clear(keepingCapacity: true)
            graphics.add(.addFilledRectangles(rects))
        }
    }

    public init(text: String = "") {
        defer {
            self.text = text
        }
        super.init()
    }
}

extension Label {
    struct Symbol {
        let size: Vector
        let rects: [Rect]

        func offset(by step: Vector, scale: Double) -> Self {
            Symbol(size: size, rects: rects.map { rect in
                Rect(
                    ((rect.origin.x + step.x) * scale),
                    ((rect.origin.y + step.y) * scale),
                    ceil(rect.width * scale),
                    ceil(rect.height * scale)
                )
            }
            )
        }
    }
}

// swiftlint:disable file_length
extension Label {
    static let symbols: [Character: Symbol] = [
        "A": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 502.95, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 125.7, width: 100.75, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55)
            ]
        ),
        "B": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 200.65, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55)
            ]
        ),
        "C": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.65, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "D": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 628.65, width: 100.75, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 125.7, width: 100.75, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "E": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 200.65, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "F": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 200.7, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "G": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "H": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 200.7, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "I": Symbol(
            size: Vector(x: 527, y: 855),
            rects: [
                Rect(x: 125, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 250.65, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 376.35, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 250.65, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 250.65, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 250.65, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 250.65, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 250.65, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 125, y: 0, width: 100.55, height: 100.55),
                Rect(x: 250.65, y: 0, width: 100.55, height: 100.55),
                Rect(x: 376.35, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "J": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 628.65, width: 100.75, height: 100.55),
                Rect(x: 452.05, y: 502.95, width: 100.75, height: 100.55),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 452.05, y: 251.35, width: 100.75, height: 100.55),
                Rect(x: 452.05, y: 125.7, width: 100.75, height: 100.55),
                Rect(x: 326.4, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "K": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 628.65, width: 100.75, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 200.7, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 125.7, width: 100.75, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "L": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.1, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "M": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.4, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 452.1, y: 125.7, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "N": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 452.1, y: 502.95, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.4, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "O": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.1, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.1, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "P": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 200.7, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.4, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.1, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.1, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "Q": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 452.1, y: 628.65, width: 100.75, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.1, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "R": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 452.1, y: 628.65, width: 100.75, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 200.7, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.4, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.1, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.1, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "S": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.65, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.9, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.9, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.9, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "T": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "U": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.65, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "V": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 628.65, width: 100.75, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "W": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.65, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "X": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 502.95, width: 100.75, height: 100.55),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 200.65, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 251.35, width: 100.75, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "Y": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "Z": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 251.35, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 200.65, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        " ": Symbol(
            size: Vector(x: 526, y: 855),
            rects: []
        ),

        "1": Symbol(
            size: Vector(x: 503, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 200.7, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 200.7, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "2": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 75, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "3": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 326.35, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 125.7, width: 100.75, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "4": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 452.05, y: 628.65, width: 100.75, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 502.95, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 200.7, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 251.35, width: 100.75, height: 100.55),
                Rect(x: 326.35, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 125.7, width: 100.75, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "5": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 251.35, width: 100.75, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "6": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 200.7, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "7": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 251.35, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 75, y: 0, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "8": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "9": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 628.65, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "0": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 200.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 75, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 75, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 75, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 577.95, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 75, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 251.35, width: 100.75, height: 100.55),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.35, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        ".": Symbol(
            size: Vector(x: 428, y: 855),
            rects: [
                Rect(x: 127, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 252.7, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 127, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 252.7, y: 628.65, width: 100.55, height: 100.55)
            ]
        ),

        ",": Symbol(
            size: Vector(x: 428, y: 855),
            rects: [
                Rect(x: 127, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 252.65, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 127, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 252.65, y: 502.95, width: 100.55, height: 100.55)
            ]
        ),

        "!": Symbol(
            size: Vector(x: 428, y: 855),
            rects: [
                Rect(x: 330, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 330, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 330, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 330, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 330, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 330, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "?": Symbol(
            size: Vector(x: 752, y: 855),
            rects: [
                Rect(x: 326.4, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 577.95, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 577.95, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 200.7, y: 0, width: 100.55, height: 100.55),
                Rect(x: 326.4, y: 0, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "(": Symbol(
            size: Vector(x: 552, y: 855),
            rects: [
                Rect(x: 376.15, y: 754.3, width: 100.75, height: 100.55),
                Rect(x: 250.5, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 124.8, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 124.8, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 124.8, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 250.5, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 376.15, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        ")": Symbol(
            size: Vector(x: 627, y: 855),
            rects: [
                Rect(x: 201, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 326.7, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 452.4, y: 502.95, width: 100.75, height: 100.55),
                Rect(x: 452.4, y: 377.05, width: 100.75, height: 100.75),
                Rect(x: 452.4, y: 251.35, width: 100.75, height: 100.55),
                Rect(x: 326.7, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 201, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "'": Symbol(
            size: Vector(x: 376, y: 855),
            rects: [
                Rect(x: 201, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 201, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "\"": Symbol(
            size: Vector(x: 627, y: 855),
            rects: [
                Rect(x: 200, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 451.35, y: 125.7, width: 100.75, height: 100.55),
                Rect(x: 200, y: 0, width: 100.55, height: 100.55),
                Rect(x: 451.35, y: 0, width: 100.75, height: 100.55)
            ]
        ),

        "|": Symbol(
            size: Vector(x: 502, y: 855),
            rects: [
                Rect(x: 327, y: 754.3, width: 100.55, height: 100.55),
                Rect(x: 327, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 327, y: 502.95, width: 100.55, height: 100.55),
                Rect(x: 327, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 327, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 327, y: 125.7, width: 100.55, height: 100.55),
                Rect(x: 327, y: 0, width: 100.55, height: 100.55)
            ]
        ),

        "\\": Symbol(
            size: Vector(x: 754, y: 855),
            rects: [
                Rect(x: 577.95, y: 628.65, width: 100.55, height: 100.55),
                Rect(x: 452.05, y: 502.95, width: 100.75, height: 100.55),
                Rect(x: 326.35, y: 377.05, width: 100.55, height: 100.75),
                Rect(x: 200.7, y: 251.35, width: 100.55, height: 100.55),
                Rect(x: 75, y: 125.7, width: 100.55, height: 100.55)
            ]
        ),

        ":": Symbol(
            size: Vector(x: 502, y: 855),
            rects: [
                Rect(x: 201, y: 628.95, width: 100.55, height: 100.55),
                Rect(x: 326.65, y: 628.95, width: 100.55, height: 100.55),
                Rect(x: 201, y: 503.25, width: 100.55, height: 100.55),
                Rect(x: 326.65, y: 503.25, width: 100.55, height: 100.55),
                Rect(x: 201, y: 251.65, width: 100.55, height: 100.55),
                Rect(x: 326.65, y: 251.65, width: 100.55, height: 100.55),
                Rect(x: 201, y: 126, width: 100.55, height: 100.55),
                Rect(x: 326.65, y: 126, width: 100.55, height: 100.55)
            ]
        ),

        ";": Symbol(
            size: Vector(x: 502, y: 855),
            rects: [
                Rect(x: 201, y: 754.6, width: 100.55, height: 100.55),
                Rect(x: 326.7, y: 628.95, width: 100.55, height: 100.55),
                Rect(x: 201, y: 503.25, width: 100.55, height: 100.55),
                Rect(x: 326.7, y: 503.25, width: 100.55, height: 100.55),
                Rect(x: 201, y: 251.65, width: 100.55, height: 100.55),
                Rect(x: 326.7, y: 251.65, width: 100.55, height: 100.55),
                Rect(x: 201, y: 126, width: 100.55, height: 100.55),
                Rect(x: 326.7, y: 126, width: 100.55, height: 100.55)
            ]
        )
    ]
}
