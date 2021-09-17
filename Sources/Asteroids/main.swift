import FirebladeECS
import AsteroidsGameLibrary
import SDLKit

// MARK: SDL and Nexus Engines Setup

// swiftlint:disable prefixed_toplevel_constant

// initialize the SDL library with video and audio
if !SDL_Init(subsystems: [.video, .audio]) {
    fatalError("could not init video/audio - reason: \(String(cString: SDL_GetError()))")
}

// description of a display mode
var displayMode = SDL_DisplayMode()
// write info about current display into description
SDL_GetCurrentDisplayMode(0, &displayMode)

// timer for game loop
var tFrame = Timer()
// timer for app life time
var tSetup = Timer()
// number of frames passed during game
var frameCount: UInt = 0
// keeps track of frames per second
var fps = 0.0

// engine that orchestrates game entities and components
let nexus = Nexus()

// start tracking setup time
tSetup.start()

var windowTitle: String { "Asteroids ECS demo: [entities:\(nexus.numEntities) components:\(nexus.numComponents) families:\(nexus.numFamilies)] @ [FPS: \(fps), frames: \(frameCount)]" }

// width and height for current display
var width: Int32 = max(displayMode.w / 2, 800)
var height: Int32 = max(displayMode.h / 2, 600)

// flags for window to be created with
let winFlags : SDL_WindowFlags = [
    .shown,     // make window visible
    .resizable  // and resizable
]
// create window
let hWin = SDL_CreateWindow(
    windowTitle,
    Int32(SDL_WINDOWPOS_CENTERED_MASK), // x
    Int32(SDL_WINDOWPOS_CENTERED_MASK), // y
    width,
    height,
    winFlags
)

// prevent game from running in case window can't be created
if hWin == nil {
    SDL_Quit()
    fatalError("could not create window")
}

// provide game controls description
func printHelp() {
    let help: String = """
    ================ FIREBLADE ASTEROIDS DEMO ===============
    press:
    ← or A     rotate spaceship to the left
    → or D     rotate spaceship to the right
    ↑ or W     accelerate spaceship
    SPACE      shoot bullet
    ESC        quit
    """
    print(help)
}

// keep track of pressed and released keys by putting them in a set
var keysDown = Set<Int32>()
// closure to be used for checking keys down within systems
let isKeyDown: (Int32) -> Bool = { keysDown.contains($0) }

// handle nexus events to keep track of what components are added to and removed from
// entities in order to let systems know about it and react accordingly
class NexusEventDelegateHandler: NexusEventDelegate {
    typealias Callback = (Component) -> Void

    var handleComponentAdded: Callback
    var handleComponentRemoved: Callback
    let componentByComponentIdEntityId: (ComponentIdentifier, EntityIdentifier) -> Component?
    // since it's not possible to use componentByComponentIdEntityId, during ComponentRemoved event, we must store
    // components in dictionary to be able to access them when they are being removed
    var components = [EntityIdentifier: [ComponentIdentifier: Component]]()

    init(nexus: Nexus, handleComponentAdded: @escaping Callback, handleComponentRemoved: @escaping Callback) {
        componentByComponentIdEntityId = { [weak nexus] in nexus?.get(safe: $0, for: $1) }
        self.handleComponentAdded = handleComponentAdded
        self.handleComponentRemoved = handleComponentRemoved
    }

    func nexusEvent(_ event: NexusEvent) {
        if let event = event as? EntityCreated {
            components[event.entityId] = [:]
        } else if let event = event as? ComponentAdded, let component = componentByComponentIdEntityId(event.component, event.toEntity) {
            components[event.toEntity]?[event.component] = component
            handleComponentAdded(component)
        } else if let event = event as? ComponentRemoved,
                  let component = components[event.from]?[event.component] {
            components[event.from]?[event.component] = nil
            handleComponentRemoved(component)
        } else if let event = event as? EntityDestroyed {
            components[event.entityId] = nil
        }
    }

    func nexusNonFatalError(_ message: String) {}
}

// lists of callbacks to be used for each system that needs them
var componentAddedCallbacks = [NexusEventDelegateHandler.Callback]()
var componentRemovedCallbacks = [NexusEventDelegateHandler.Callback]()

let delegate = NexusEventDelegateHandler(
    nexus: nexus,
    handleComponentAdded: { component in for callback in componentAddedCallbacks { callback(component) } },
    handleComponentRemoved: { component in for callback in componentRemovedCallbacks { callback(component) } }
)

nexus.delegate = delegate

// MARK: - Systems Setup

// game config that is shared between the systems
let config = GameConfig(width: Double(width), height: Double(height))
// root display object container where other renderable objects are added to
let scene = Renderable()
// factory for all entites that is shared between the systems
let entityCreator = EntityCreator(nexus: nexus, config: config)
// responsible for laying out UI
let layoutSystem = LayoutSystem(config: config, nexus: nexus)
// manages when to start game
let waitForStartSystem = WaitForStartSystem(creator: entityCreator, nexus: nexus, config: config)
// desides when spaceship is going back to the game after destruction or when to move to
// the next level
let gameManager = GameManagementSystem(creator: entityCreator, config: config, nexus: nexus)
// observes the motion related keys being pressed and moves entities accordingly
let motionControlSystem = MotionControlSystem(isKeyDown: isKeyDown, nexus: nexus)
// observes the shoot key being pressed and lets shooting
let gunControlSystem = GunControlSystem(isKeyDown: isKeyDown, creator: entityCreator, nexus: nexus)
// keeps track of how much time bullet is allowed to fly
let bulletAgeSystem = BulletAgeSystem(creator: entityCreator, nexus: nexus)
// responsible for how long dying action occurs also destroys entity afterwards
let deathThroesSystem = DeathThroesSystem(creator: entityCreator, nexus: nexus)
// keeps entities in motion
let movementSystem = MovementSystem(config: config, nexus: nexus)
// handles collision detection and provides reaction to it
let collisionSystem = CollisionSystem(creator: entityCreator, nexus: nexus)
// handles animation
let animationSystem = AnimationSystem(nexus: nexus)
// updates indicators of spaceship lives and scores
let hudSystem = HudSystem(nexus: nexus)
// renders scene
let renderSystem = RenderSystem(window: hWin,
                                scene: scene,
                                handleComponentAdded: { callback in
                                    componentAddedCallbacks.append(callback)
                                },
                                handleComponentRemoved: { callback in
                                    componentRemovedCallbacks.append(callback)
                                },
                                nexus: nexus)
// plays sound effects
let audioSystem = AudioSystem(nexus: nexus)

// create intro/game over screen
entityCreator.createWaitForClick()
// create game
entityCreator.createGame()

// stop measuring how much time setup has taken
tSetup.stop()
print("[SETUP]: took \(tSetup.milliSeconds)ms")

// timer for game lifetime
var tRun = Timer()
// show controls info in console
printHelp()
// start tracking game lifetime
tRun.start()

// container for sdl events to be written to during game loop
var event = SDL_Event()
// flag for quitting app
var quit: Bool = false
// container to store current time
var currentTime: UInt32 = 0
// container to store previous 'currentTime'
var lastTime: UInt32 = 0
// list of time for frame
var frameTimes: [UInt64] = []

print("================ RUNNING ================")

// position window in the center of the screen
SDL_SetWindowPosition(hWin,
                      Int32(SDL_WINDOWPOS_CENTERED_MASK),
                      Int32(SDL_WINDOWPOS_CENTERED_MASK)
)

// forward event to view and its children
func push(event: Event, to parent: Renderable) {
    parent.handleEvent?(event)
    for child in parent.children {
        push(event: event, to: child)
    }
}

// last dispatched mouse down event
var prevMouseDown: (x: Sint32, y: Sint32)?

// MARK: - Game Loop

// perform game loop unti quit is requested
while quit == false {
    // start measure time for frame
    tFrame.start()
    // while event is received process its type
    while SDL_PollEvent(&event) == 1 {
        // determine what kind of event is received in order to react to it
        switch event.eventType {
        case SDL_QUIT:
            quit = true

        case SDL_WINDOWEVENT where event.windowEvent == SDL_WINDOWEVENT_SIZE_CHANGED:
            width = Int32(event.window.data1)
            height = Int32(event.window.data2)

        case SDL_KEYDOWN:
            keysDown.insert(event.key.keysym.sym)
            switch event.keyCode {
            case SDLK_ESCAPE:
                quit = true

            default:
                break
            }

        case SDL_KEYUP:
            keysDown.remove(event.key.keysym.sym)
        // handle left mouse button down
        case SDL_MOUSEBUTTONDOWN where event.button.button == 1:
            push(event: .mouseDown(
                    position: Vector(
                        x: Double(event.button.x),
                        y: Double(event.button.y)
                    ),
                    time: Double( event.button.timestamp)),
                 to: scene)
            prevMouseDown = (x: event.button.x, y: event.button.y)
        // handle left mouse button up
        case SDL_MOUSEBUTTONUP where event.button.button == 1:
            push(event: .mouseUp(
                    position: Vector(
                        x: Double(event.button.x),
                        y: Double(event.button.y)
                    ),
                    time: Double( event.button.timestamp)),
                 to: scene)

            if let (x, y) = prevMouseDown, event.button.x == x, event.button.y == y {
                push(event: .click(.init(x: Double(x), y: Double(y))),
                     to: scene)
            }
            prevMouseDown = .none

        default:
            break
        }
    }

    // wait until 16ms has elapsed since last frame
    while !(SDL_GetTicks() >= currentTime + 16) {}

    // delta time is the difference in ticks from last frame
    // also it is clamped by maximum delta time value to 0.05 for
    // avoiding too much of oveshooting if for example game was paused and resummed by debugger
    let delta = min(Double(SDL_GetTicks() - currentTime) / 1000.0, 0.05)

    // update all systems
    layoutSystem.update()
    waitForStartSystem.update()
    gameManager.update(time: delta)
    motionControlSystem.update(time: delta)
    gunControlSystem.update(time: delta)
    bulletAgeSystem.update(time: delta)
    deathThroesSystem.update(time: delta)
    movementSystem.update(time: delta)
    collisionSystem.update(time: delta)
    animationSystem.update(time: delta)
    hudSystem.update()
    renderSystem.render()
    audioSystem.update()

    // stop measuring frame time
    tFrame.stop()

    // store frames in container
    frameTimes.append(tFrame.nanoSeconds)

    // Print a report once per second
    currentTime = SDL_GetTicks()
    if currentTime > lastTime + 1000 {
        let count = UInt(frameTimes.count)
        // add up number of frames
        frameCount += count
        // sum all frame time together
        let sum: UInt64 = frameTimes.reduce(0, +)
        // clear frame time list but keeping it's capacity for better performance
        frameTimes.removeAll(keepingCapacity: true)
        // calculate avarage number of nanoseconds to determine fps
        let averageNanos = Double(sum) / Double(count)
        // calculate fps
        fps = 1.0 / (averageNanos * 1.0e-9) // 1.0e-9 is 1 nanosecond
        // round calculated fps to look nice
        fps.round()
        // render updated window title
        SDL_SetWindowTitle(hWin, windowTitle)
        // store current time in last time to have 1 second window title updates
        lastTime = currentTime
    }
    // reset frame timer for next tick
    tFrame.reset()
}

// at this point some cleanup is required:
// remove window from memory
SDL_DestroyWindow(hWin)
// shut down SDL
SDL_Quit()
// measure time game ran
tRun.stop()
// report to console time game took while being run
print("[RUN]: took \(tRun.seconds)s")
