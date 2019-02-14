import CSDL2
import FirebladeECS

let kDefaultVelocity: Double = 6.0
var tFrame = Timer()
var tSetup = Timer()
var velocity: Double = kDefaultVelocity
var currentCount: Int = 0

tSetup.start()
if SDL_Init(SDL_INIT_VIDEO) != 0 {
    fatalError("could not init video")
}

var frameCount: UInt = 0
var fps: Double = 0
let nexus = Nexus()

var windowTitle: String {
    return "Fireblade ECS demo: [entities:\(nexus.numEntities) components:\(nexus.numComponents) families:\(nexus.numFamilies) velocity:\(velocity)] @ [FPS: \(fps), frames: \(frameCount)]"
}
let width: Int32 = 800
let height: Int32 = 600
let winFlags: UInt32 = SDL_WINDOW_SHOWN.rawValue | SDL_WINDOW_RESIZABLE.rawValue
let hWin = SDL_CreateWindow(windowTitle, 100, 100, width, height, winFlags)

if hWin == nil {
    SDL_Quit()
    fatalError("could not crate window")
}

func randNorm() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
}

// won't produce pure black
func randColor() -> UInt8 {
    return UInt8(randNorm() * 254) + 1
}

class Position: Component {
    var x: Int32 = width/2
    var y: Int32 = height/2
}
class Color: Component {
    var r: UInt8 = randColor()
    var g: UInt8 = randColor()
    var b: UInt8 = randColor()
}

func createScene() {

    let numEntities: Int = 10_000

    for i in 0..<numEntities {
        createDefaultEntity(name: "\(i)")
    }
}

func batchCreateEntities(count: Int) {
    for i in 0..<count {
        createDefaultEntity(name: "\(i)")
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
    e.assign(Position())
    e.assign(Color())
}

class PositionSystem {
    let family = nexus.family(requires: Position.self)

    func update() {

        family
            .forEach { (pos: Position) in

                let deltaX: Double = velocity*((randNorm() * 2) - 1)
                let deltaY: Double = velocity*((randNorm() * 2) - 1)
                var x = pos.x + Int32(deltaX)
                var y = pos.y + Int32(deltaY)

                if x < 0 || x > width {
                    x = -x
                }
                if y < 0 || y > height {
                    y = -y
                }

                pos.x = x
                pos.y = y
        }
    }

}

class PositionResetSystem {
    let family = nexus.family(requires: Position.self)

    func update() {
        family
            .forEach { (pos: Position) in
                pos.x = width/2
                pos.y = height/2
        }
    }
}

class ColorSystem {
    let family = nexus.family(requires: Color.self)

    func update() {

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

        SDL_SetRenderDrawColor( hRenderer, 0, 0, 0, 255 ) // black
        SDL_RenderClear(hRenderer) // clear screen

        family
            .forEach { [weak self] (pos: Position, color: Color) in
                guard let `self` = self else {
                    return
                }

                var rect = SDL_Rect(x: pos.x, y: pos.y, w: 2, h: 2)

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
let colorSystem = ColorSystem()

func printHelp() {
    let help: String = """
	================ FIREBLADE ECS DEMO ===============
	press:
	ESC		quit
	c		change all colors (random)
	r		reset all positions (to center)
	s		stop movement
	+		increase movement speed
	-		reduce movement speed
	space	reset to default movement speed
	e		create 1 entity
	d		destroy 1 entity
	8		batch create 10k entities
	9		batch destroy 10k entities
	"""
    print(help)
}

createScene()
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
print("================ RUNNING ================")
SDL_SetWindowPosition(hWin, Int32(SDL_WINDOWPOS_CENTERED_MASK), Int32(SDL_WINDOWPOS_CENTERED_MASK))
while quit == false {
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
                colorSystem.update()
            case SDLK_r:
                positionResetSystem.update()
            case SDLK_s:
                velocity = 0.0
            case SDLK_PLUS:
                velocity += 0.1
            case SDLK_MINUS:
                velocity -= 0.1
            case SDLK_SPACE:
                velocity = kDefaultVelocity
            case SDLK_e:
                batchCreateEntities(count: 1)
            case SDLK_d:
                batchDestroyEntities(count: 1)
            case SDLK_8:
                batchCreateEntities(count: 10_000)
            case SDLK_9:
                batchDestroyEntities(count: 10_000)
            default:
                break
            }
        default:
            break
        }
    }

    positionSystem.update()

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

        let avergageNanos: Double = Double(sum)/Double(count)

        fps = 1.0 / (avergageNanos * 1.0e-9)
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
