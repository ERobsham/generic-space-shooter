package space_shooter

import "core:fmt"
import "vendor:sdl2"

import "../lib"
import "../lib/collision"
import "../lib/move"
import "../lib/deltaT"

import "input"


PLAYER_SS_IDX :: 0
PLAYER_SS_COL_X :: 0
PLAYER_SS_ROW_Y :: 0
PLAYER_SPRITE_W :: 50
PLAYER_SPRITE_H :: 57

PLAYER_MOVE_SPEED :: 500.0

Player :: struct {
    using gObj: lib.GameObject,

    processKeyboardInput: proc(self: ^Player, game_state: ^GameState, keyboard_state: [^]u8),

    sprite: SpriteCoords,
}

InitPlayer :: proc() -> Player {
    p := Player{
        loc = { (W_WIDTH  / 2), (W_HEIGHT / 2) * 1.25 },
        dir = { 0, 0 },
        speed = PLAYER_MOVE_SPEED,
        
        dimensions= { PLAYER_SPRITE_W, PLAYER_SPRITE_H },

        sprite = {
            tx = PLAYER_SS_COL_X * SPRITESHEET_DIM,
            ty = PLAYER_SS_ROW_Y * SPRITESHEET_DIM,
            w = PLAYER_SPRITE_W,
            h = PLAYER_SPRITE_H,
        },

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

ProcessPlayerInput :: proc(player: ^Player, game_state: ^GameState, keyboard_state: [^]u8) {
    move_dir := input.GetMoveDir(keyboard_state)
    player.dir = move.VecFor(move_dir)

    shooting := input.GetShootingState(keyboard_state)
    if shooting {
        // add a projectile to game state
    }
}

UpdatePlayer :: proc(player: ^Player, dt: f64) {
    lib.MoveWithin(cast(^lib.GameObject)player, WindowBB, dt)

    // other things?
}

DrawPlayer :: proc(player: ^Player, renderer: ^sdl2.Renderer) {
    DrawSprite(renderer, 
        PLAYER_SS_IDX,
        player.sprite, 
        lib.GetBoundingBox(cast(^lib.GameObject)player),
    )
}
