package space_shooter

import "core:fmt"
import "core:math/rand"
import "vendor:sdl2"

import "../lib"
import "../lib/physics2d"

POWERUP_SPAWN_CHANCE :f64: 1.0/10.0

GameState :: struct {
    using api : SpaceShooterAPI,

    window_bounds : physics2d.BoundingBox,

    // game objects
    player      : Player,
    enemies     : [dynamic]Enemy,
    projectiles : [dynamic]Projectile,
    powerups    : [dynamic]Powerup,
    misc_objs   : [dynamic]^lib.GameObject,

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
    s.addPowerup = proc(self: ^SpaceShooterAPI, powerup: Powerup) {
        AddPowerup(cast(^GameState)self, powerup)
    }
    s.addMisc = proc(self: ^SpaceShooterAPI, misc: ^lib.GameObject) {
        AddMisc(cast(^GameState)self, misc)
    }
    s.windowBB = proc(self: ^SpaceShooterAPI) -> physics2d.BoundingBox {
        bb := (cast(^GameState)self).window_bounds
        return bb
    }
    
    s.window_bounds = WindowBB

    s.player        = InitPlayer()
    s.player.api = s
    s.enemies       = make([dynamic]Enemy, 0, 20)
    s.projectiles   = make([dynamic]Projectile, 0, 20)
    s.powerups      = make([dynamic]Powerup, 0, 20)
    s.misc_objs     = make([dynamic]^lib.GameObject, 0, 20)

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
    player_bb := lib.GetBoundingBox(&player)

    for &enemy in enemies {
        enemy->update(dt)

        if enemy.destroyed do continue

        enemy_bb := lib.GetBoundingBox(&enemy)
        if enemy_bb->isColliding(player_bb) {
            PlayerDestroyed(&player)
            EnemeyDestroyed(&enemy)
            break
        }
    }
    for &proj in projectiles {
        proj->update(dt)

        if proj.destroyed do continue

        proj_bb := lib.GetBoundingBox(&proj)
        if proj.is_friendly {
            for &enemy in enemies {
                if enemy.destroyed do continue
                enemy_bb := lib.GetBoundingBox(&enemy)

                if proj_bb->isColliding(enemy_bb) {
                    proj.destroyed = true
                    EnemeyDestroyed(&enemy)
                    maybeSpawnPowerup(s, &enemy_bb)
                    break
                }
            }
        }
        else if !proj.is_friendly {
            if proj_bb->isColliding(player_bb) {
                proj.destroyed = true
                PlayerDestroyed(&player)
                break
            }
        }
    }
    for &powerup in powerups {
        powerup->update(dt)

        if powerup.destroyed do continue

        powerup_bb := lib.GetBoundingBox(&powerup)
        if powerup_bb->isColliding(player_bb) {
            powerup.destroyed = true
            // TODO: power up player
            ApplyPowerupToPlayer(&player, powerup.type)
            break
        }
    }

    for &misc_obj in misc_objs {
        misc_obj->update(dt)
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
    for &powerup in powerups {
        if powerup.destroyed do continue
        powerup->draw(renderer)
    }
    
    for &misc_obj in misc_objs {
        if misc_obj.destroyed do continue
        misc_obj->draw(renderer)
    }
}

PostDrawCleanup :: proc(s: ^GameState) {
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
    for i := 0; i < len(powerups); i += 1 {
        if powerups[i].destroyed {
            unordered_remove(&powerups, i)
            i-=1
        }
    }


    for i := 0; i < len(misc_objs); i += 1 {
        if misc_objs[i].destroyed {
            free(misc_objs[i])
            unordered_remove(&misc_objs, i)
            i-=1
        }
    }
}

maybeSpawnPowerup :: proc(s: ^GameState, bb: ^physics2d.BoundingBox) {
    roll := rand.float64()
    if roll > POWERUP_SPAWN_CHANCE do return
    
    type := rand.choice(powerupTypes)
    center := bb->getCenter()
    pu := CreatePowerup(center, type)
    s->addPowerup(pu)
}
