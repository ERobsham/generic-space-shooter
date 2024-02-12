package space_shooter

import "vendor:sdl2"

import "../lib"
import "../lib/collision"

SpaceShooterAPI :: struct {
    using gsAPI   : lib.GameStateAPI,
    addEnemy      : proc(self: ^SpaceShooterAPI, enemy: Enemy),
    addProjectile : proc(self: ^SpaceShooterAPI, proj: Projectile),
    addPowerup    : proc(self: ^SpaceShooterAPI, powerup: lib.GameObject),
    windowBB      : proc(self: ^SpaceShooterAPI) -> collision.BoundingBox,
}

GameState :: struct {
    using api : SpaceShooterAPI,

    window_bounds : collision.BoundingBox,

    // game objects
    player      : Player,
    enemies     : [dynamic]Enemy,
    projectiles : [dynamic]Projectile,
    powerUps    : [dynamic]lib.GameObject,

    // systems
    enemy_spawner : EnemySpawner,
}

InitGameState :: proc(window: ^sdl2.Window, renderer: ^sdl2.Renderer) -> ^GameState {
    InitSpriteSheets(renderer, {
        "assets/player.png", // ssIdx == 0
    })

    s := new(GameState)
    s.addEnemy = proc(self: ^SpaceShooterAPI, enemy: Enemy) {
        AddEnemy(cast(^GameState)self, enemy)
    }
    s.addProjectile = proc(self: ^SpaceShooterAPI, proj: Projectile) {
        AddProjectile(cast(^GameState)self, proj)
    }
    s.addPowerup = proc(self: ^SpaceShooterAPI, powerup: lib.GameObject) {
        AddPowerup(cast(^GameState)self, powerup)
    }
    s.windowBB = proc(self: ^SpaceShooterAPI) -> collision.BoundingBox {
        bb := (cast(^GameState)self).window_bounds
        return bb
    }
    
    s.window_bounds = WindowBB

    s.player        = InitPlayer()
    s.player.api = s
    s.enemies       = make([dynamic]Enemy, 0, 20)
    s.projectiles   = make([dynamic]Projectile, 0, 20)
    s.powerUps      = make([dynamic]lib.GameObject, 0, 20)

    s.enemy_spawner = NewEnemySpawner(s)

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
    
    enemy_spawner->update(dt)

    player->update(dt)

    for &enemy in enemies {
        enemy->update(dt)
    }
    for &proj in projectiles {
        proj->update(dt)

        if proj.destroyed do continue

        proj_bb := lib.GetBoundingBox(&proj)
        if proj.is_friendly {
            for &enemy in enemies {
                if enemy.destroyed do continue
                enemy_bb := lib.GetBoundingBox(&enemy)

                if collision.IsColliding(proj_bb, enemy_bb) {
                    proj.destroyed = true
                    enemy.destroyed = true
                    break
                }
            }
        }
        else if !proj.is_friendly {
            player_bb := lib.GetBoundingBox(&player)
            if collision.IsColliding(proj_bb, player_bb) {
                proj.destroyed = true
                player.destroyed = true
                break
            }
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


//
// space shooter 'API' methods
//

AddEnemy :: proc(api: ^GameState, enemy: Enemy) {
    e := enemy
    e.api = api
    append(&api.enemies, e)
}

AddProjectile :: proc(api: ^GameState, proj: Projectile) {
    p := proj
    p.api = api
    append(&api.projectiles, p)
}

AddPowerup :: proc(api: ^GameState, power_up: lib.GameObject) {
    p := power_up
    p.api = api
    append(&api.powerUps, p)
}
