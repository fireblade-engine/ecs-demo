//
//  RenderSystem.swift
//  FirebladeECSDemo
//
//  Created by Igor Kravchenko on 11.10.2020.
//

import FirebladeECS
import AsteroidsGameLibrary
import SDLKit

final class RenderSystem {
    typealias Parallel = (@escaping (Component) -> Void) -> Void
    private let renderer: OpaquePointer?
    private let scene: Renderable
    private let renderables: Family2<Display, Position>

    private var rectangles = [SDL_FRect]()

    init(window: OpaquePointer?,
         scene: Renderable,
         handleComponentAdded: @escaping Parallel,
         handleComponentRemoved: @escaping Parallel,
         nexus: Nexus) {
        // use hardware accelerated renderer
        let flags: SDL_RendererFlags = [.accelerated]
        renderer = SDL_CreateRenderer(window,
                                      -1, // -1 to initialize the first driver supporting the requested flags
                                      flags)
        self.scene = scene
        if renderer == nil {
            SDL_DestroyWindow(window)
            SDL_Quit()
            fatalError("unable to create renderer")
        }

        handleComponentAdded { component in
            guard let display = component as? Display else {
                return
            }
            scene.addChild(display.renderable)
        }

        handleComponentRemoved { component in
            guard let display = component as? Display else {
                return
            }
            scene.removeChild(display.renderable)
        }

        renderables = nexus.family(requiresAll: Display.self, Position.self)
    }

    func render() {
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255)
        SDL_RenderClear(renderer)
        for (display, position) in renderables {
            display.renderable.position = position.position
            display.renderable.rotation = position.rotation
        }
        SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255)
        renderChild(scene)

        SDL_RenderFillRectsF(renderer, rectangles, Int32(rectangles.count))

        rectangles.removeAll(keepingCapacity: true)

        SDL_RenderPresent(renderer)
    }

    private func renderChild(_ child: Renderable) {
        for nestedChild in child.children {
            renderChild(nestedChild)
        }

        var mtx = Matrix()
        mtx.scale(by: child.scale)
        mtx.rotate(child.rotation)
        mtx.translate(by: child.position)
        if let parent = child.parent {
            var parentMtx = Matrix()
            parentMtx.scale(by: parent.scale)
            parentMtx.rotate(parent.rotation)
            parentMtx.translate(by: parent.position)
            mtx *= parentMtx
        }

        var vectors: [Vector]
        for command in child.graphics.commands {
            switch command {
            case let .addFilledRectangles(rects):
                rectangles
                    .append(contentsOf: rects
                                .map { rect in
                                    let newOrigin = mtx.transformedVector(rect.origin.vector)
                                    return SDL_FRect(
                                        x: Float(newOrigin.x),
                                        y: Float(newOrigin.y),
                                        w: Float(rect.width * child.scale.x),
                                        h: Float(rect.height * child.scale.y)
                                    )
                                }
                    )

            case let .addPath(path):
                for line in path.lines {
                    vectors = line
                    mtx.transformVectors(&vectors)
                    drawLines(renderer: renderer, lines: vectors, closedPath: false)
                }
            }
        }
    }

    private final func drawLines(renderer: OpaquePointer?, lines: [Vector], closedPath: Bool) {
        assert(lines.count >= 2, "count of elements in provided list must be at least 2, currently it is \(lines.count)")
        SDL_RenderDrawLinesF(renderer, lines.map { SDL_FPoint(x: Float($0.x), y: Float($0.y)) }, Int32(lines.count))
        guard closedPath else {
            return
        }
        SDL_RenderDrawLineF(renderer,
                            Float(lines[lines.count - 1].x),
                            Float(lines[lines.count - 1].y),
                            Float(lines[0].x),
                            Float(lines[0].y))
    }

    deinit {
        SDL_DestroyRenderer(renderer)
    }
}
