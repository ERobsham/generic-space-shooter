package space_shooter

import "core:c"
import "core:fmt"
import "vendor:sdl2"

import "../lib"
import "../lib/collision"
import "../lib/move"
import "../lib/deltaT"

import "input"


PLAYER_SPRITE :: SpriteInfo {
    ss_idx = 0,
    t_col = 0,
    t_row = 0,
    t_w = 50,
    t_h = 57,
}

PLAYER_MOVE_SPEED :: 500.0
PLAYER_ROF        :f64: 1.0/8.0 // ie shots per sec


Player :: struct {
    using gObj: lib.GameObject,

    processKeyboardInput: proc(self: ^Player, keyboard_state: [^]u8),

    sprite: SpriteInfo,
    
    facing: move.Dir,
    shot_cooldown: f64,
}

InitPlayer :: proc() -> Player {
    p := Player{
        loc = { (W_WIDTH  / 2), (W_HEIGHT / 2) * 1.25 },
        dir = { 0, 0 },
        speed = PLAYER_MOVE_SPEED,
        
        dimensions= { PLAYER_SPRITE.t_w, PLAYER_SPRITE.t_h },

        sprite = PLAYER_SPRITE,
        facing = move.Dir.North,

        shot_cooldown = 0.0,

        processKeyboardInput = ProcessPlayerInput,

        update = proc(self: ^lib.GameObject, dt: f64) {
            UpdatePlayer(cast(^Player)self, dt)
        },
        draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
            DrawPlayer(cast(^Player)self, renderer)
        },
    }
    return p
}

ProcessPlayerInput :: proc(player: ^Player, keyboard_state: [^]u8) {
    using player
    
    move_dir := input.GetMoveDir(keyboard_state)
    dir = move.VecFor(move_dir)

    shooting := input.GetShootingState(keyboard_state)
    if shooting && shot_cooldown <= 0 {
        shot_cooldown = PLAYER_ROF
        
        bb := lib.GetBoundingBox(player)
        center := bb->getCenter()
        // center.y += ( f64(dimensions.h) / 2 )

        // add a projectile to game state
        proj := CreateProjectile(center, move.VecFor(facing))
        (cast(^SpaceShooterAPI)api)->addProjectile(proj)
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
