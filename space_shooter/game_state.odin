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

InitGameState :: proc(window: ^sdl2.Window, renderer: ^sdl2.Renderer) -> ^GameState {
    InitSpriteSheets(renderer, {
        "assets/player.png", // ssIdx == 0
    })

    s := new(GameState)
    s.window_bounds = WindowBB
    s.player        = InitPlayer()
    s.enemies       = make([dynamic]Enemy, 0, 20)
    s.projectiles   = make([dynamic]Projectile, 0, 20)

    // give players a ref to the world state so they can spawn projectiles, etc
    s.player.game_state = s

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

    player->processKeyboardInput(key_states)
}

UpdateGameState :: proc(s: ^GameState, dt: f64) {
    using s
    
    player->update(dt)

    for &enemy in enemies {
        enemy->update(dt)

        bb := lib.GetBoundingBox(cast(^lib.GameObject)&enemy)
        if !collision.IsColliding(bb, window_bounds) {
            // we're outside the window bounds. dispose of this
            enemy.destroyed = true
        }
    }
    for &proj in projectiles {
        proj->update(dt)

        bb := lib.GetBoundingBox(cast(^lib.GameObject)&proj)
        if !collision.IsColliding(bb, window_bounds) {
            // we're outside the window bounds. dispose of this
            proj.destroyed = true
        }
    }
}

DrawGameState :: proc(s: ^GameState, renderer: ^sdl2.Renderer) {
    using s
    
    player->draw(renderer)

    for &enemy in enemies {
        if enemy.destroyed do continue
        enemy->draw(renderer)
    }
    for &proj in projectiles {
        if proj.destroyed do continue
        proj->draw(renderer)
    }
}

PostDrawCleanup :: proc (s: ^GameState) {
    using s
    
    // remove any 'destroyed' objects
    for i := 0; i < len(enemies); i += 1 {
        if enemies[i].destroyed {
            unordered_remove(&enemies, i)
            i-=1
        }
    }
    for i := 0; i < len(projectiles); i += 1 {
        if projectiles[i].destroyed {
            unordered_remove(&projectiles, i)
            i-=1
        }
    }
}
