package space_shooter

import "vendor:sdl2"

import "../lib"
import "../lib/move"

ENEMY_SPRITE :: SpriteInfo {
    ss_idx = 0,
    t_col = 0,
    t_row = 2,
    t_w = 48,
    t_h = 16,
}

ENEMY_MOVE_SPEED :: 400.0

Enemy :: struct {
    using gObj: lib.GameObject,

    sprite: SpriteInfo,
}

CreateEnemy :: proc(at: move.Vec2, initial_dir: move.Vec2) -> Enemy {
    return Enemy {
        loc = at,
        dimensions = { PROJECTILE_SPRITE.t_w, PROJECTILE_SPRITE.t_h },
        
        dir = initial_dir,
        speed = PROJECTILE_SPEED,

        sprite = PROJECTILE_SPRITE,

        update = proc(self: ^lib.GameObject, dt: f64) {
            UpdateEnemy(cast(^Enemy)self, dt)
        },
        draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
            DrawEnemy(cast(^Enemy)self, renderer)
        },
    }
}

UpdateEnemy :: proc(enemy: ^Enemy, dt: f64) {
    lib.Move(cast(^lib.GameObject)enemy, dt)
}

DrawEnemy :: proc(enemy: ^Enemy, renderer: ^sdl2.Renderer) {
    using enemy
    
    if destroyed do return

    DrawSprite(renderer, 
        sprite, 
        lib.GetBoundingBox(cast(^lib.GameObject)enemy),
    )
}
