package space_shooter

import "vendor:sdl2"

import "../lib"
import "../lib/move"
import "../lib/collision"

ENEMY_SPRITE :: SpriteInfo {
    ss_idx = 0,
    t_col = 0,
    t_row = 2,
    t_w = 48,
    t_h = 16,
}

ENEMY_MOVE_SPEED :: 400.0

EnemyState :: enum {
    APPROACH,
    ENGAGE,
    FLEE,
}

EnemyState_TransistionTime := [EnemyState]f64 {
    .APPROACH = 1.5,
    .ENGAGE = 5,
    .FLEE = -1,
}

Enemy :: struct {
    using gObj: lib.GameObject,

    sprite: SpriteInfo,

    state             : EnemyState,
    state_trans_cd    : f64,
    engage_dir_swap_cd: f64,
}

CreateEnemy :: proc(at: move.Vec2, initial_dir: move.Vec2) -> Enemy {
    return Enemy {
        loc = at,
        dimensions = { ENEMY_SPRITE.t_w, ENEMY_SPRITE.t_h },
        
        dir = initial_dir,
        speed = ENEMY_MOVE_SPEED,

        sprite = ENEMY_SPRITE,

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

    window_bounds := (cast(^SpaceShooterAPI)enemy.api)->windowBB()
    bb := lib.GetBoundingBox(cast(^lib.GameObject)enemy)
    if !collision.IsColliding(bb, window_bounds) {
        // we're outside the window bounds. dispose of this
        enemy.destroyed = true
    }
}

DrawEnemy :: proc(enemy: ^Enemy, renderer: ^sdl2.Renderer) {
    using enemy
    
    if destroyed do return

    DrawSprite(renderer, 
        sprite, 
        lib.GetBoundingBox(cast(^lib.GameObject)enemy),
    )
}
