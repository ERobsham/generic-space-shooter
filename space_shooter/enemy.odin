package space_shooter

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

ENEMY_MOVE_SPEED     :: 150.0
ENEMY_PROJ_SPEED_MOD :: 0.5

ENEMY_DIR_ROC :: 1.5
ENEMY_ROF     :: 1.25


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
    .APPROACH = UpdateEnemy_Approach,
    .ENGAGE = UpdateEnemy_Engage,
    .FLEE = UpdateEnemy_Approach, // does the same thing for now -- just moves in the current direction
}

Enemy :: struct {
    using gObj: lib.GameObject,

    sprite: SpriteInfo,

    facing: Dir,

    state             : EnemyState,
    state_trans_cd    : f64,
    
    engage_dir_change_cd: f64,
    engage_shoot_cd     : f64,
}

CreateEnemy :: proc(at: physics2d.Vec2, initial_dir: Dir) -> Enemy {
    return Enemy {
        loc = at,
        dimensions = { f64(ENEMY_SPRITE.t_w), f64(ENEMY_SPRITE.t_h) },
        
        dir = VecFor(initial_dir),
        speed = ENEMY_MOVE_SPEED,

        sprite = ENEMY_SPRITE,
        facing = initial_dir,

        update = proc(self: ^lib.GameObject, dt: f64) {
            UpdateEnemy(cast(^Enemy)self, dt)
        },
        draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
            DrawEnemy(cast(^Enemy)self, renderer)
        },

        state = EnemyState.APPROACH,
        state_trans_cd = EnemyState_TransistionTime[EnemyState.APPROACH],
    }
}

UpdateEnemy :: proc(enemy: ^Enemy, dt: f64) {
    using enemy
    state_trans_cd -= dt

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

                // ensure we're not `.Stationary` right now
                new_dir := facing
                #partial switch facing {
                    case .Stationary:
                        new_dir = Dir.North
                    case .South, .SouthEast, .SouthWest:
                        new_dir = ReverseDir(facing)
                    case .East:
                        new_dir = Dir.NorthEast
                    case .West:
                        new_dir = Dir.NorthWest
                }
                ChangeEnemyDirection(enemy, new_dir)
            }
            case .FLEE: {
                destroyed = true
            }
        }
    }

    updateProc := EnemyState_UpdateProcs[state]

    updateProc(enemy, dt)

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

ChangeEnemyDirection :: proc(enemy: ^Enemy, new_dir: Dir) {
    using enemy
    dir = VecFor(new_dir)
    facing = new_dir
}

UpdateEnemy_Approach :: proc(enemy: ^Enemy, dt: f64) {
    using enemy

    lib.Move(cast(^lib.GameObject)enemy, dt)
}

UpdateEnemy_Engage :: proc(enemy: ^Enemy, dt: f64) {
    using enemy

    if engage_dir_change_cd <= 0 {
        engage_dir_change_cd = ENEMY_DIR_ROC
        new_dir := RandomDir()
        ChangeEnemyDirection(enemy, new_dir)
    }
    if engage_shoot_cd <= 0 {
        engage_shoot_cd = ENEMY_ROF
        bb := lib.GetBoundingBox(enemy)
        center := bb->getCenter()
        
        proj := CreateProjectile(center, VecFor(Dir.South), false)
        proj.speed = u32(f64(proj.speed) * ENEMY_PROJ_SPEED_MOD)
        (cast(^SpaceShooterAPI)api)->addProjectile(proj)
    }

    engage_dir_change_cd -= dt
    engage_shoot_cd -= dt
    
    
    window_bounds := (cast(^SpaceShooterAPI)api)->windowBB()
    window_bounds.dimensions.h = ((window_bounds.dimensions.h/4) * 3)
    
    lib.MoveWithin(cast(^lib.GameObject)enemy, window_bounds, dt)

    // try to avoid hugging edges or getting too low on the screen
    // ( at least for too long )
    buffer :: 20 // px
    switch {
        case dir.x <= 0 && loc.x                     < f64(window_bounds.origin.x + buffer)                    :
            fallthrough
        case dir.x >= 0 && loc.x + f64(dimensions.w) > f64(window_bounds.origin.x + window_bounds.dimensions.w + buffer)  :
            fallthrough
        case dir.y <= 0 && loc.y                     < f64(window_bounds.origin.y + buffer)                    :
            fallthrough
        case dir.y <= 0 && loc.y + f64(dimensions.h) > f64(window_bounds.origin.y + window_bounds.dimensions.h + buffer)  :
            engage_dir_change_cd -= (dt * 10)
    }
}

EnemeyDestroyed :: proc(enemy: ^Enemy) {
    using enemy
    enemy.destroyed = true

    bb := lib.GetBoundingBox(enemy)
    center := bb->getCenter()

    expl := CreateExplosionPtr(center)
    (cast(^SpaceShooterAPI)api)->addMisc(expl)
}
