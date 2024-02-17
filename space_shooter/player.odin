package space_shooter

import "core:c"
import "core:fmt"
import "core:math"
import "vendor:sdl2"

import "../lib"
import "../lib/deltaT"
import "../lib/physics2d"


PLAYER_SPRITE :: SpriteInfo {
    ss_idx = 0,
    t_col = 0,
    t_row = 0,
    t_w = 50,
    t_h = 57,
}

PLAYER_MOVE_SPEED :: 500.0
PLAYER_ROF        :f64: 4.0 // ie shots per sec

PLAYER_MULITI_SHOT_MAX :: 9

playerProjOrigins := [PLAYER_MULITI_SHOT_MAX]shotOrigin {
    { { 25,  0 }, .North }, // tip - top center
    { {  0, 40 }, .North }, // far left - wing tip
    { { 50, 40 }, .North }, // far right - wing tip
    { { 15, 10 }, .North }, // offset left - top
    { { 40, 10 }, .North }, // offset right - top
    { {  0, 40 }, .NorthWest },
    { { 50, 40 }, .NorthEast },
    { { 25,  0 }, .NorthWest },
    { { 25,  0 }, .NorthEast },
}

Player :: struct {
    using gObj: lib.GameObject,

    processKeyboardInput: proc(self: ^Player, keyboard_state: [^]u8),

    sprite: SpriteInfo,
    facing: Dir,
    
    shot_cooldown: f64,
    rof_mod      : f64,

    multi_shot    : u8,
    punch_through : u8,
    shot_speed_mod: f64,
}

shotOrigin :: struct {
    offset: physics2d.Vec2,
    dir: Dir,
}

InitPlayer :: proc() -> Player {
    p := Player{
        loc = { (W_WIDTH  / 2), (W_HEIGHT / 2) * 1.25 },
        dir = { 0, 0 },
        speed = PLAYER_MOVE_SPEED,
        
        dimensions= { f64(PLAYER_SPRITE.t_w), f64(PLAYER_SPRITE.t_h) },

        sprite = PLAYER_SPRITE,
        facing = Dir.North,

        processKeyboardInput = ProcessPlayerInput,

        update = proc(self: ^lib.GameObject, dt: f64) {
            UpdatePlayer(cast(^Player)self, dt)
        },
        draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
            DrawPlayer(cast(^Player)self, renderer)
        },

        shot_cooldown = 0,
        rof_mod       = 1.0,

        multi_shot     = 0,
        punch_through  = 0,
        shot_speed_mod = 1.0,
    }
    return p
}

ProcessPlayerInput :: proc(player: ^Player, keyboard_state: [^]u8) {
    using player
    
    move_dir := GetMoveDir(keyboard_state)
    dir = VecFor(move_dir)

    shooting := GetShootingState(keyboard_state)
    if shooting && shot_cooldown <= 0 {
        shot_cooldown = 1.0 / (PLAYER_ROF * rof_mod)
        GeneratePlayerProjectiles(player)
    }
}

UpdatePlayer :: proc(player: ^Player, dt: f64) {
    using player
    lib.MoveWithin(cast(^lib.GameObject)player, WindowBB, dt)

    if shot_cooldown > 0 do shot_cooldown -= dt
    
    // other things?
}

DrawPlayer :: proc(player: ^Player, renderer: ^sdl2.Renderer) {
    using player
    DrawSprite(renderer,
        sprite,
        lib.GetBoundingBox(cast(^lib.GameObject)player),
    )
}

PlayerDestroyed :: proc(player: ^Player) {
    using player
    destroyed = true

    bb := lib.GetBoundingBox(player)
    center := bb->getCenter()

    expl := CreateExplosionPtr(center)
    (cast(^SpaceShooterAPI)api)->addMisc(expl)
}

GeneratePlayerProjectiles :: proc(player: ^Player) {
    using player

    // if mulit_shot == 1, we want to shoot balanced from two sides
    offset := u8(multi_shot % 2 == 1 ? 1 : 0)

    for i := u8(0 + offset); i <= (multi_shot + offset); i += 1 {
        shot_origin := playerProjOrigins[i]
        
        shot_loc := physics2d.Vec2 {
            loc.x + shot_origin.offset.x,
            loc.y + shot_origin.offset.y,
        }
        
        // we want more like NNE/NNW, so make some custom adjustments for now.
        shot_dir := VecFor(shot_origin.dir)
        if shot_dir.x > 0 {
            shot_dir = { +1/math.SQRT_FIVE, -2/math.SQRT_FIVE }
        } 
        else if shot_dir.x < 0 {
            shot_dir = { -1/math.SQRT_FIVE, -2/math.SQRT_FIVE }
        }

        proj := CreateProjectile(shot_loc, shot_dir)
        proj.speed = u32(f64(proj.speed) * shot_speed_mod)

        (cast(^SpaceShooterAPI)api)->addProjectile(proj)
    }
}
