//
//  Animation.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 18.11.2020.
//

import FirebladeECS
import AsteroidsGameLibrary

final class Animation: ComponentInitializable {
    var animation: Animatable

    init(animation: Animatable) {
        self.animation = animation
    }

    required init() {
        animation = AnimationPlaceholder()
    }
}

class AnimationPlaceholder: Renderable, Animatable {
    private static let starPoints: [Vector] = [
        .init(x: 0, y: -26.75),
        .init(x: 9.43, y: -12.98),
        .init(x: 25.44, y: -8.27),
        .init(x: 15.26, y: 4.96),
        .init(x: 15.72, y: 21.64),
        .init(x: 0, y: 16.05),
        .init(x: -15.72, y: 21.64),
        .init(x: -15.26, y: 4.96),
        .init(x: -25.44, y: -8.27),
        .init(x: -9.43, y: -12.98),
    ]
    
    private var step = 0.0
    
    func animate(time: Double) {
        step += time
        
        if step >= .pi * 2 {
            step = .zero
        }
        
        graphics.clear(keepingCapacity: true)
        var mtx = Matrix()
        mtx.rotate(step)
        var points = Self.starPoints
        mtx.transformVectors(&points)
        var path = Graphics.Path()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.close()
        graphics.add(.addPath(path))
    }
}
