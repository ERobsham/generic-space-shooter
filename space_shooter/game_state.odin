package space_shooter

import "vendor:sdl2"

import "../lib"
import "../lib/collision"

GameState :: struct {
    window_bounds : collision.BoundingBox,

    // game objects
    player      : Player,
    enemies     : [dynamic]Enemy,
    projectiles : [dynamic]Projectile,
}

InitGameState :: proc(window: ^sdl2.Window, renderer: ^sdl2.Renderer) -> GameState {
    InitSpriteSheets(renderer, {
        "assets/player.png", // ssIdx == 0
    })

    s := GameState {
        window_bounds = WindowBB,

        player      = InitPlayer(),
        enemies     = make([dynamic]Enemy, 0, 20),
        projectiles = make([dynamic]Projectile, 0, 20),
    }

    return s
}

DestroyGameState :: proc(s: ^GameState) {
    DestroySpriteSheets()

    delete(s.enemies)
    delete(s.projectiles)
}

ProcessKeyboardInput :: proc(s: ^GameState) {
    using s
    // get keyboard state
    key_states := sdl2.GetKeyboardState(nil)

    player->processKeyboardInput(s, key_states)
}

UpdateGameState :: proc(s: ^GameState, dt: f64) {
    using s
    
    player->update(dt)
}

DrawGameState :: proc(s: ^GameState, renderer: ^sdl2.Renderer) {
    using s
    
    player->draw(renderer)

    // move enemies / projectiles

    // check for collisions
}


PostDrawCleanup :: proc (s: ^GameState) {
    // remove any 'destroyed' objects
}