package space_shooter

import "core:math/rand"
import "vendor:sdl2"

import "../lib"
import "../lib/physics2d"

ENEMY_SPRITE :: SpriteInfo {
    ss_idx = 0,
    t_col = 0,
    t_row = 2,
    t_w = 48,
    t_h = 16,
}

ENEMY_MOVE_SPEED     :: 1.0
ENEMY_PROJ_SPEED_MOD :: 0.5

ENEMY_ROF     :: 1.0
ENEMY_SHOT_CHANCE :: 1.0/4.0


EnemyState :: enum {
    APPROACH,
    ENGAGE,
    FLEE,
}

EnemyState_TransistionTime := [EnemyState]f64 {
    .APPROACH = 1,
    .ENGAGE = 10,
    .FLEE = 10,
}

EnemyState_UpdateProcs := [EnemyState]proc(enemy: ^Enemy, dt: f64) {
    .APPROACH = UpdateEnemy_Engage,
    .ENGAGE = UpdateEnemy_Engage,
    .FLEE = UpdateEnemy_Engage, // does the same thing for now -- just moves in the current direction
}

Enemy :: struct {
    using gObj: lib.GameObject,

    sprite: SpriteInfo,

    state             : EnemyState,
    state_trans_cd    : f64,
    
    engage_shoot_cd     : f64,

    total_t: f64,
    move_path: ^physics2d.Spline,
}

CreateEnemy :: proc(at: physics2d.Vec2, path: ^physics2d.Spline) -> Enemy {
    return Enemy {
        loc = at,
        dimensions = { f64(ENEMY_SPRITE.t_w), f64(ENEMY_SPRITE.t_h) },
        
        dir = { 0, 0 },
        speed = ENEMY_MOVE_SPEED,

        sprite = ENEMY_SPRITE,

        update = proc(self: ^lib.GameObject, dt: f64) {
            UpdateEnemy(cast(^Enemy)self, dt)
        },
        draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
            DrawEnemy(cast(^Enemy)self, renderer)
        },

        state = EnemyState.APPROACH,
        state_trans_cd = EnemyState_TransistionTime[EnemyState.APPROACH],

        total_t = 0,
        move_path = path,
    }
}

UpdateEnemy :: proc(enemy: ^Enemy, dt: f64) {
    using enemy
    state_trans_cd -= dt
    total_t += dt

    should_transition := (state_trans_cd <= 0)
    
    if should_transition {
        switch state {
            case .APPROACH: {
                state = EnemyState.ENGAGE
                state_trans_cd = EnemyState_TransistionTime[EnemyState.ENGAGE]
            }
            case .ENGAGE: {
                state = EnemyState.FLEE
                state_trans_cd = EnemyState_TransistionTime[EnemyState.FLEE]

                speed = u32( f64(speed) * 2.5 )
            }
            case .FLEE: {
                destroyed = true
            }
        }
    }

    updateProc := EnemyState_UpdateProcs[state]
    updateProc(enemy, dt)

    if state == EnemyState.APPROACH do return

    window_bounds := (cast(^SpaceShooterAPI)enemy.api)->windowBB()
    bb := lib.GetBoundingBox(cast(^lib.GameObject)enemy)
    if !bb->isColliding(window_bounds) {
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

UpdateEnemy_Approach :: proc(enemy: ^Enemy, dt: f64) {
    using enemy

    lib.Move(cast(^lib.GameObject)enemy, dt)
}

UpdateEnemy_Engage :: proc(enemy: ^Enemy, dt: f64) {
    using enemy

    if engage_shoot_cd <= 0 {
        engage_shoot_cd = ENEMY_ROF

        roll := rand.float64()
        if ENEMY_SHOT_CHANCE >= roll {
            bb := lib.GetBoundingBox(enemy)
            center := bb->getCenter()
            
            proj := CreateProjectile(center, VecFor(Dir.South), false)
            proj.speed = u32(f64(proj.speed) * ENEMY_PROJ_SPEED_MOD)
            (cast(^SpaceShooterAPI)api)->addProjectile(proj)
        }
    }

    engage_shoot_cd -= dt
    
    dist := f64(speed) * total_t
    if dist > f64(move_path->length()) do return
    
    new_loc := move_path->pointAt(dist)
    loc.x = new_loc.x
    loc.y = new_loc.y
}

EnemeyDestroyed :: proc(enemy: ^Enemy) {
    using enemy
    enemy.destroyed = true

    bb := lib.GetBoundingBox(enemy)
    center := bb->getCenter()

    expl := CreateExplosionPtr(center)
    (cast(^SpaceShooterAPI)api)->addMisc(expl)
}
