import CSDL2
import FirebladeECS
import os

let log = OSLog(subsystem: "com.fireblade.ecs-demp", category: .pointsOfInterest)

var tFrame = Timer()
var tSetup = Timer()
var simSpeed: Double = 4.0
var currentCount: Int = 0

tSetup.start()
if SDL_Init(SDL_INIT_VIDEO) != 0 {
    fatalError("could not init video")
}

var frameCount: UInt = 0
var fps: Double = 0
let nexus = Nexus()

var windowTitle: String {
    return "Fireblade ECS demo: [entities:\(nexus.numEntities) components:\(nexus.numComponents) families:\(nexus.numFamilies) simSpeed:\(simSpeed)] @ [FPS: \(fps), frames: \(frameCount)]"
}
let width: Int32 = 800
let height: Int32 = 600
let winFlags: UInt32 = SDL_WINDOW_SHOWN.rawValue | SDL_WINDOW_RESIZABLE.rawValue
let hWin = SDL_CreateWindow(windowTitle, 100, 100, width, height, winFlags)

if hWin == nil {
    SDL_Quit()
    fatalError("could not create window")
}

func randNorm() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
}

// won't produce pure black
func randColor() -> UInt8 {
    return UInt8(randNorm() * 253) + 1
}

class Position: Component, Locatable, Equatable {
    static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    func distance(_ other: Position) -> Double {
        let deltaX = Double(self.x - other.x)
        let deltaY = Double(self.y - other.y)

        return sqrt(Double(deltaX * deltaX) + Double(deltaY * deltaY))
    }

    var x: Int32 = width/2
    var y: Int32 = height/2
}
class Velocity: Component {
    var x: Double = 0
    var y: Double = 0
}
class Facing: Component {
    // currently basically equivalent to the direction part of Velocity
    // since we cannot distinguish the facing of our blobs anyway =P
    var x: Double = 0
    var y: Double = 1
}
class Alignment: Component {
    var x: Double = 0
    var y: Double = 1
}
class Cohesion: Component {
    var x: Double = 0
    var y: Double = 0
}
class Dispersion: Component {
    var x: Double = 0
    var y: Double = 0
}
class Color: Component {
    var r: UInt8 = 250
    var g: UInt8 = 0
    var b: UInt8 = 0
}

class ColoredPosition: Position {
    var r: Int32 = 255
    var g: Int32 = 255
    var b: Int32 = 255

}

final class Grid: SpatialIndex {
    typealias type = Position

    private let gridSize: Int32
    private let tileSize: Int32
    private var tiles: ContiguousArray<ContiguousArray<Position>>

    init(_ gridSize: Int32, _ width: Double, _ height: Double) {
        self.gridSize = gridSize
        tileSize = Int32(ceil(Double(max(width, height)) / Double(gridSize)))
        tiles = ContiguousArray<ContiguousArray<Position>>(repeating: [], count: Int(gridSize * gridSize))
    }

    @inlinable
    func toGridIndex(_ locatable: type) -> Int {
        let xIndex = locatable.x / tileSize
        let yIndex = gridSize * (locatable.y / tileSize)
        return Int(xIndex + yIndex)
    }

    @discardableResult
    func add(_ locatable: type) -> Bool {
        tiles[toGridIndex(locatable)].append(locatable)
        return true
    }

    func allWithinBounds(_ others: [type]) -> [type] {
        return []
    }

    final func allWithinDistance(_ other: type, _ distance: Double) -> [type] {

        // heuristic 1: we don't give much of a crap and always limit us to the `other`'s
        // native grid index when searching and also do not filter results by distance
        // note:
        // this heuristic is NOT optimal since it may include `other`s in the grid
        // tile whose distance is higher requested
        // it is also NOT admissible since it will miss `other`s within distance but in
        // another grid tile
        //        return tiles[toGridIndex(other)]

        // heuristic 2: as `1` but now filtering results by distance
        // note:
        // NOT admissible, optimal
        return tiles[toGridIndex(other)].filter { $0.distance(other) <= distance }

        // heuristic 3: as `2`, but including grid `n` steps out, where `n` is ceil(distance / tileSize)
        // admissible, optimal
    }
}

class SpatialIndexSystem {
    typealias type = Position
    let family = nexus.family(requiresAll: Position.self, Color.self)
    var index = Grid(gridSize, Double(width), Double(height))

    func update() {
        os_signpost(.begin, log: log, name: "SpatialIndexSystem")
        defer { os_signpost(.end, log: log, name: "SpatialIndexSystem") }
        index = Grid(gridSize, Double(width), Double(height))
        family.forEach { (pos: Position, col: Color) in
            let cpos = ColoredPosition()
            cpos.x = pos.x
            cpos.y = pos.y
            cpos.r = Int32(col.r)
            cpos.g = Int32(col.g)
            cpos.b = Int32(col.b)
            index.add(cpos)
        }

    }
}

func createScene() {

    //    let numEntities: Int = 10_000
    let numEntities: Int = 2_500
    //    let numEntities: Int = 1_000

    for i in 0..<numEntities {
        createDefaultEntity(name: "\(i)")
    }
}

func batchCreateEntities(count: Int) {
    for _ in 0..<count {
        createDefaultEntity(name: nil)
    }
}

func batchDestroyEntities(count: Int) {
    let family = nexus.family(requires: Position.self)
    family
        .entities
        .prefix(count)
        .forEach { (entity: Entity) in
            entity.destroy()
    }

}

func createDefaultEntity(name: String?) {
    let e = nexus.create(entity: name)
    let pos = Position()
    pos.x = (Int32 (randNorm() * (Double (width))))
    pos.y = (Int32 (randNorm() * (Double (height))))
    let vel = Velocity()
    vel.x = Double.random(in: -1.0...1.0)
    vel.y = Double.random(in: -1.0...1.0)
    e.assign(pos)
    e.assign(Color())
    e.assign(vel)
    e.assign(Facing())
    e.assign(Alignment())
    e.assign(Cohesion())
    e.assign(Dispersion())
}

class PositionSystem {
    let family = nexus.family(requiresAll: Position.self, Velocity.self)

    func update() {
        os_signpost(.begin, log: log, name: "PositionSystem")
        defer { os_signpost(.end, log: log, name: "PositionSystem") }
        family
            .forEach { (pos: Position, vel: Velocity) in

                let deltaX: Double = simSpeed*(vel.x)
                let deltaY: Double = simSpeed*(vel.y)
                let x = pos.x + Int32(deltaX)
                let y = pos.y + Int32(deltaY)

                // bouncy borders
                if (x >= width) {
                    pos.x -= x - width
                    vel.x *= -1
                } else if (x <= 0) {
                    pos.x = -1 * x
                    vel.x *= -1
                } else {
                    pos.x = x
                }
                if (y >= height) {
                    pos.y -= y - height
                    vel.y *= -1
                } else if (y <= 0) {
                    pos.y = -1 * y
                    vel.y *= -1
                } else {
                    pos.y = y
                }

                // wrappy borders
                //                pos.x = x % width
                //                if (pos.x < 0) {
                //                    pos.x += width
                //                }
                //                pos.y = y % height
                //                if (pos.y < 0) {
                //                    pos.y += height
                //                }
        }
    }
}

var gridSize: Int32 = 32
var colorMapping: Array<Color> = Array()
var greyScale = false

func initialiseColorMapping(_ greyScale: Bool = true) {
    let count: Int = Int(gridSize * gridSize)
    colorMapping = [Color]()
    for _ in 0..<count {
        colorMapping.append(Color())
    }
    let multiplier: Double = 1 / Double(gridSize * gridSize)
    for i in 0..<count {
        if (greyScale) {
            colorMapping[i].r = UInt8(255 * multiplier * Double(i))
            colorMapping[i].g = UInt8(255 * multiplier * Double(i))
            colorMapping[i].b = UInt8(255 * multiplier * Double(i))
        } else {
            colorMapping[i].r = randColor()
            colorMapping[i].g = randColor()
            colorMapping[i].b = randColor()
        }
    }
}

class ColorGridSystem {
    let tileSize: Int32 = Int32(ceil(Double(max(width, height)) / Double(gridSize)))

    let family = nexus.family(requiresAll: Position.self, Color.self)

    func update() {
        os_signpost(.begin, log: log, name: "ColorGridSystem")
        defer { os_signpost(.end, log: log, name: "ColorGridSystem") }
        family.forEach {(pos: Position, col: Color) in
            let xIndex = pos.x / tileSize
            let yIndex = gridSize * (pos.y / tileSize)
            let index = Int(xIndex + yIndex)
            col.r = colorMapping[index].r
            col.g = colorMapping[index].g
            col.b = colorMapping[index].b
        }
    }
}
class ColorNeighbourSystem {
    let tileSize: Int32 = Int32(ceil(Double(max(width, height)) / Double(gridSize)))
    let family = nexus.family(requiresAll: Position.self, Color.self)

    func update2(_ sis: SpatialIndexSystem) {
        os_signpost(.begin, log: log, name: "ColorNeighbourSystem")
        defer { os_signpost(.end, log: log, name: "ColorNeighbourSystem") }

        family.forEach { (pos: Position, col: Color) in
            let neighbours = sis.index.allWithinDistance(pos, Double(tileSize) / 5)
            let acc = ColoredPosition()
            acc.r = Int32(col.r)
            acc.g = Int32(col.g)
            acc.b = Int32(col.b)

            let centerOfGravity = neighbours
                .compactMap { $0 as? ColoredPosition }
                .reduce(acc) { (acc: ColoredPosition, next: ColoredPosition) in
                    acc.r += next.r
                    acc.g += next.g
                    acc.b += next.b
                    return acc
            }

            let nCount = Int32(neighbours.count + 1)

            col.r = UInt8((centerOfGravity).r / nCount)
            col.g = UInt8((centerOfGravity).g / nCount)
            col.b = UInt8((centerOfGravity).b / nCount)

            if (Int(col.r) + Int(col.g) + Int(col.b) < 150
                || abs((Int(col.r) + Int(col.g) + Int(col.b)) / 3 - Int(col.r)) < 25) {
                col.r = randColor()
                col.g = randColor()
                col.b = randColor()
            }
        }
    }
}

class AlignmentSystem {
    let tileSize: Int32 = Int32(ceil(Double(max(width, height)) / Double(gridSize)))
    var alignments = [Int: (Int, (Double, Double))]()

    let family = nexus.family(requiresAll: Position.self, Velocity.self, Alignment.self)

    func update() {
        os_signpost(.begin, log: log, name: "AlignmentSystem")
        defer { os_signpost(.end, log: log, name: "AlignmentSystem") }
        initialise()
        family.forEach { (pos: Position, vel: Velocity, _: Alignment) in
            let xIndex = pos.x / tileSize
            let yIndex = gridSize * (pos.y / tileSize)
            let index = Int(xIndex + yIndex)

            var alignment = alignments[index]!
            alignment.0 += 1
            alignments[index] = (alignment.0, (alignment.1.0 + vel.x/Double(alignment.0), alignment.1.1 + vel.y/Double(alignment.0)))
        }
        family.forEach { (pos: Position, vel: Velocity, alg: Alignment) in
            let xIndex = pos.x / tileSize
            let yIndex = gridSize * (pos.y / tileSize)
            let index = Int(xIndex + yIndex)
            let alignment = alignments[index]!
            let mag = sqrt(alignment.1.0*alignment.1.0 + alignment.1.1*alignment.1.1)

            //            vel.x *= Double.random(in: 0.8...1.2)
            //            vel.y *= Double.random(in: 0.8...1.2)
            if (mag != 0) {
                alg.x = (alignment.1.0 / mag)
                alg.y = (alignment.1.1 / mag)

                vel.x = (vel.x * 0.85 + alg.x * 0.15)
                vel.y = (vel.y * 0.85 + alg.y * 0.15)
            }
        }
    }
    func initialise() {
        for i in 0..<(gridSize*gridSize) {
            alignments[Int(i)] = (0, (0.0, 0.0))
        }
    }
}

class CohesionSystem {
    let tileSize: Int32 = Int32(ceil(Double(max(width, height)) / Double(gridSize)))
    var cohesionCenters = [Int: (Int, (Double, Double))]()

    let family = nexus.family(requiresAll: Position.self, Cohesion.self, Velocity.self)

    func update2(_ sis: SpatialIndexSystem) {
        os_signpost(.begin, log: log, name: "CohesionSystem")
        defer { os_signpost(.end, log: log, name: "CohesionSystem") }
        family.forEach { (pos: Position, coh: Cohesion, vel: Velocity) in
            let neighbours = sis.index.allWithinDistance(pos, Double(tileSize) / 5)
            let acc = Position()
            acc.x = pos.x
            acc.y = pos.y

            let centerOfGravity = neighbours.reduce(acc, { (acc: Position, next: Position) in
                acc.x += next.x
                acc.y += next.y
                return acc
            })

            if (neighbours.count != 0) {
                centerOfGravity.x /= Int32(neighbours.count)
                centerOfGravity.y /= Int32(neighbours.count)
                centerOfGravity.x -= pos.x
                centerOfGravity.y -= pos.y
            }
            let mag = sqrt(Double(centerOfGravity.x*centerOfGravity.x + centerOfGravity.y*centerOfGravity.y))

            if (mag != 0 && neighbours.count != 0) {
                coh.x = (Double(centerOfGravity.x) / mag)
                coh.y = (Double(centerOfGravity.y) / mag)

                //                if (vel.x < 0) {
                //                    coh.x *= -1
                //                }
                //                if (vel.y < 0) {
                //                    coh.y *= -1
                //                }
                vel.x = (vel.x * 0.975 + coh.x * 0.025)
                vel.y = (vel.y * 0.975 + coh.y * 0.025)
            }
        }
    }

    func update() {
        os_signpost(.begin, log: log, name: "CohesionSystem")
        defer { os_signpost(.end, log: log, name: "CohesionSystem") }
        initialise()

        family.forEach { (pos: Position, _: Cohesion, _) in
            let xIndex = pos.x / tileSize
            let yIndex = gridSize * (pos.y / tileSize)
            let index = Int(xIndex + yIndex)

            var cohesion = cohesionCenters[index]!
            cohesion.0 += 1
            cohesionCenters[index] = (cohesion.0, (cohesion.1.0 + Double(pos.x)/Double(cohesion.0), cohesion.1.1 + Double(pos.y)/Double(cohesion.0)))
        }

        family.forEach { (pos: Position, coh: Cohesion, vel: Velocity) in
            let xIndex = pos.x / tileSize
            let yIndex = gridSize * (pos.y / tileSize)
            let index = Int(xIndex + yIndex)
            let cohesion = cohesionCenters[index]!
            coh.x = (cohesion.1.0 - Double(pos.x))
            coh.y = (cohesion.1.1 - Double(pos.y))
            let mag = sqrt(coh.x*coh.x + coh.y*coh.y)

            if (mag != 0) {
                coh.x = coh.x / mag
                coh.y = coh.y / mag
                //            assert(coh.x > 0)
                //            assert(coh.y > 0)

                vel.x = (vel.x * 0.9 + coh.x * 0.1)
                vel.y = (vel.y * 0.9 + coh.y * 0.1)
            }

        }
    }
    func initialise() {
        for i in 0..<(gridSize*gridSize) {
            cohesionCenters[Int(i)] = (0, (0.0, 0.0))
        }
    }
}

class DispersionSystem {
    let tileSize: Int32 = Int32(ceil(Double(max(width, height)) / Double(gridSize)))
    var cohesionCenters = [Int: (Int, (Double, Double))]()

    let family = nexus.family(requiresAll: Position.self, Dispersion.self, Velocity.self)

    func update2(_ sis: SpatialIndexSystem) {
        os_signpost(.begin, log: log, name: "DispersionSystem")
        defer { os_signpost(.end, log: log, name: "DispersionSystem") }
        family.forEach { (pos: Position, coh: Dispersion, vel: Velocity) in
            let neighbours = sis.index.allWithinDistance(pos, Double(tileSize) / 10)
            let centerOfGravity = neighbours.reduce(Position(), { (acc: Position, next: Position) in
                acc.x += next.x
                acc.y += next.y
                return acc
            })

            if (neighbours.count > 5) {
                vel.x += Double.random(in: -1.0...1.0)
                vel.y += Double.random(in: -1.0...1.0)
                vel.x *= -1
                vel.y *= -1
                return
            } else {
                return
            }

            if (neighbours.count != 0) {
                centerOfGravity.x /= Int32(neighbours.count)
                centerOfGravity.y /= Int32(neighbours.count)
            }
            let mag = sqrt(Double(centerOfGravity.x*centerOfGravity.x + centerOfGravity.y*centerOfGravity.y))

            if (mag != 0 && neighbours.count != 0) {
                coh.x = (Double(centerOfGravity.x) / mag)
                coh.y = (Double(centerOfGravity.y) / mag)

                //                vel.x = (vel.x * 0.05 + coh.x * 0.95)
                //                vel.y = (vel.y * 0.05 + coh.y * 0.95)
            }
        }
    }

    func update() {
        os_signpost(.begin, log: log, name: "DispersionSystem")
        defer { os_signpost(.end, log: log, name: "DispersionSystem") }
        initialise()
        family.forEach { (pos: Position, _: Dispersion, _) in
            let xIndex = pos.x / tileSize
            let yIndex = gridSize * (pos.y / tileSize)
            let index = Int(xIndex + yIndex)

            var cohesion = cohesionCenters[index]!
            cohesion.0 += 1
            cohesionCenters[index] = (cohesion.0, (cohesion.1.0 + Double(pos.x)/Double(cohesion.0), cohesion.1.1 + Double(pos.y)/Double(cohesion.0)))
        }
        family.forEach { (pos: Position, coh: Dispersion, vel: Velocity) in
            let xIndex = pos.x / tileSize
            let yIndex = gridSize * (pos.y / tileSize)
            let index = Int(xIndex + yIndex)
            let cohesion = cohesionCenters[index]!
            coh.x = (cohesion.1.0 - Double(pos.x))
            coh.y = (cohesion.1.1 - Double(pos.y))
            //            coh.x = (-cohesion.1.0 + Double(pos.x))
            //            coh.y = (-cohesion.1.1 + Double(pos.y))
            let mag = sqrt(coh.x*coh.x + coh.y*coh.y)

            if (mag != 0) {
                coh.x = coh.x / mag
                coh.y = coh.y / mag

                //            assert(coh.x > 0)
                //            assert(coh.y > 0)

                if (cohesion.0 > 5) {
                    //                vel.x *= -1
                    //                vel.y *= -1
                    vel.x = (vel.x * 0.15 - coh.x * 0.85) * 3
                    vel.y = (vel.y * 0.15 - coh.y * 0.85) * 3
                }
            }
        }
    }
    func initialise() {
        for i in 0..<(gridSize*gridSize) {
            cohesionCenters[Int(i)] = (0, (0.0, 0.0))
        }
    }
}

//class SwarmSystem {
//
//    let partitionSystem: PartitionSystem
//
//    init(partitionSystem: PartitionSystem) {
//        self.partitionSystem = partitionSystem
//    }
//
//    let family = nexus.family(requiresAll: Position.self, Velocity.self)
//
//    func update() {
//        family.forEach {(pos: Position, vel: Velocity) in
//        }
//    }
//}

class PositionResetSystem {
    let family = nexus.family(requiresAll: Position.self, Velocity.self)

    func update() {
        os_signpost(.begin, log: log, name: "PositionResetSystem")
        defer { os_signpost(.end, log: log, name: "PositionResetSystem") }
        family
            .forEach { (pos: Position, vel: Velocity) in
                pos.x = (Int32 (randNorm() * (Double (width))))
                pos.y = (Int32 (randNorm() * (Double (height))))
                vel.x = Double.random(in: -1.0...1.0) * 1
                vel.y = Double.random(in: -1.0...1.0) * 1
        }
    }
}

class ColorSystem {
    let family = nexus.family(requires: Color.self)

    func update() {
        os_signpost(.begin, log: log, name: "ColorSystem")
        defer { os_signpost(.end, log: log, name: "ColorSystem") }
        family
            .forEach { (color: Color) in
                color.r = randColor()
                color.g = randColor()
                color.b = randColor()
        }
    }
}

class RenderSystem {
    let hRenderer: OpaquePointer?
    let family = nexus.family(requiresAll: Position.self, Color.self)

    init(hWin: OpaquePointer?) {
        let flags: UInt32 = SDL_RENDERER_ACCELERATED.rawValue | SDL_RENDERER_PRESENTVSYNC.rawValue
        hRenderer = SDL_CreateRenderer(hWin, -1, flags)
        if hRenderer == nil {
            SDL_DestroyWindow(hWin)
            SDL_Quit()
            fatalError("could not create renderer")
        }
    }

    deinit {
        SDL_DestroyRenderer(hRenderer)
    }

    func render() {
        os_signpost(.begin, log: log, name: "RenderSystem")
        defer { os_signpost(.end, log: log, name: "RenderSystem") }
        SDL_SetRenderDrawColor( hRenderer, 0, 0, 0, 255 ) // black
        SDL_RenderClear(hRenderer) // clear screen

        family
            .forEach { [weak self] (pos: Position, color: Color) in
                guard let `self` = self else {
                    return
                }

                var rect = SDL_Rect(x: pos.x, y: pos.y, w: 2, h: 2)
                //                print(color.r, color.g, color.b)
                SDL_SetRenderDrawColor(self.hRenderer, color.r, color.g, color.b, 255)
                SDL_SetRenderDrawBlendMode(self.hRenderer, SDL_BLENDMODE_NONE)
                SDL_RenderFillRect(self.hRenderer, &rect)
        }

        SDL_RenderPresent(hRenderer)
    }
}
let positionSystem = PositionSystem()
let positionResetSystem = PositionResetSystem()
let renderSystem = RenderSystem(hWin: hWin)
//let colorSystem = ColorSystem()
var colorGridSystem = ColorGridSystem()
var alignmentSystem = AlignmentSystem()
alignmentSystem.initialise()
var cohesionSystem = CohesionSystem()
cohesionSystem.initialise()
var dispersionSystem = DispersionSystem()
dispersionSystem.initialise()
var colourNeighbourSystem = ColorNeighbourSystem()

func printHelp() {
    let help: String = """
    ================ FIREBLADE ECS DEMO ===============
    width:  \(width)
    height: \(height)
    grid size: \(gridSize)
    press:
    ESC		quit
    c		change all colors (random)
    r		reset all positions (to center)
    s		stop movement
    +		increase sim speed
    -		reduce sim speed
    space	reset to default sim speed
    e		create 1 entity
    d		destroy 1 entity
    8		batch create 10k entities
    9		batch destroy 10k entities
    ,       increase grid size by one
    .       decrease grid size by one
    ;       double grid size
    :       half grid size
    g       toggle greyscale
    """
    print(help)
}

createScene()
var spatialIndexSystem = SpatialIndexSystem()
spatialIndexSystem.update()
tSetup.stop()
print("[SETUP]: took \(tSetup.milliSeconds)ms")
var tRun = Timer()
printHelp()

tRun.start()
var event: SDL_Event = SDL_Event()
var quit: Bool = false
var currentTime: UInt32 = 0
var lastTime: UInt32 = 0
var frameTimes: [UInt64] = []
initialiseColorMapping(greyScale)
print("================ RUNNING ================")
SDL_SetWindowPosition(hWin, Int32(SDL_WINDOWPOS_CENTERED_MASK), Int32(SDL_WINDOWPOS_CENTERED_MASK))
while quit == false {
    os_signpost(.begin, log: log, name: "Loop")
    defer { os_signpost(.end, log: log, name: "Loop") }
    tFrame.start()
    while SDL_PollEvent(&event) == 1 {
        switch SDL_EventType(rawValue: event.type) {
        case SDL_QUIT:
            quit = true
            break
        case SDL_KEYDOWN:
            switch Int(event.key.keysym.sym) {
            case SDLK_ESCAPE:
                quit = true
                break
            case SDLK_c:
                colorGridSystem.update()
                colourNeighbourSystem.update2(spatialIndexSystem)
            //                colorSystem.update()
            case SDLK_r:
                positionResetSystem.update()
                spatialIndexSystem.update()
            case SDLK_s:
                simSpeed = 0.0
            case SDLK_PLUS:
                simSpeed += 0.1
            case SDLK_MINUS:
                simSpeed -= 0.1
            case SDLK_SPACE:
                simSpeed = 4.0
            case SDLK_e:
                batchCreateEntities(count: 1)
            case SDLK_d:
                batchDestroyEntities(count: 1)
            case SDLK_8:
                batchCreateEntities(count: 10_000)
            case SDLK_9:
                batchDestroyEntities(count: 10_000)
            case SDLK_COMMA:
                gridSize = max(1, gridSize - 1)
                initialiseColorMapping(greyScale)
                colorGridSystem = ColorGridSystem()
            case SDLK_PERIOD:
                gridSize = gridSize + 1
                initialiseColorMapping(greyScale)
                colorGridSystem = ColorGridSystem()
            case SDLK_SEMICOLON:
                gridSize = max(1, Int32(pow(2, log2(Double(gridSize)) - 1)))
                initialiseColorMapping(greyScale)
                colorGridSystem = ColorGridSystem()
            case SDLK_COLON:
                gridSize = Int32(pow(2, log2(Double(gridSize)) + 1))
                initialiseColorMapping(greyScale)
                colorGridSystem = ColorGridSystem()
            case SDLK_g:
                greyScale = !greyScale
                initialiseColorMapping(greyScale)
            default:
                break
            }
        default:
            break
        }
    }

    spatialIndexSystem.update()
    //    colorGridSystem.update()
    alignmentSystem.update()
    cohesionSystem.update2(spatialIndexSystem)
    dispersionSystem.update2(spatialIndexSystem)
    positionSystem.update()
    colourNeighbourSystem.update2(spatialIndexSystem)

    renderSystem.render()
    tFrame.stop()

    frameTimes.append(tFrame.nanoSeconds)

    // Print a report once per second
    currentTime = SDL_GetTicks()
    if (currentTime > lastTime + 1000) {

        let count = UInt(frameTimes.count)
        frameCount += count
        let sum: UInt64 = frameTimes.reduce(0, { $0 + $1 })
        frameTimes.removeAll(keepingCapacity: true)

        let average: Double = Double(sum)/Double(count)

        fps = 1.0 / (average * 1.0e-9)
        fps.round()

        SDL_SetWindowTitle(hWin, windowTitle)
        lastTime = currentTime
    }
    tFrame.reset()
}

SDL_DestroyWindow(hWin)
SDL_Quit()
tRun.stop()
print("[RUN]: took \(tRun.seconds)s")
