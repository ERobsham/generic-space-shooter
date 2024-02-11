package main

import "vendor:sdl2"

PLAYER_SPRITESHEET_IDX_X :: 0
PLAYER_SPRITESHEET_IDX_Y :: 0
PLAYER_SPRITE_W :: 50
PLAYER_SPRITE_H :: 57

// px/sec
PLAYER_MOVE_SPEED :: 500.0

Player :: struct {
    loc: Vec2,
    dir: Vec2,

    sprite: SpriteCoords,
}

NewPlayer :: proc(renderer: ^sdl2.Renderer) -> Player {
    return Player{
        loc = {
            (W_WIDTH  / 2), 
            (W_HEIGHT / 2),
        },
        dir = { 0, 0 },
        
        sprite = {
            tx = PLAYER_SPRITESHEET_IDX_X * SPRITESHEET_DIM,
            ty = PLAYER_SPRITESHEET_IDX_Y * SPRITESHEET_DIM,
            w = 50, 
            h = 57,
        },
    }
}

DrawPlayer :: proc(player: ^Player, renderer: ^sdl2.Renderer) {
    DrawSprite(renderer, player.sprite, GetPlayerBoundingBox(player))
}

MovePlayer :: proc(player: ^Player, deltaT_ms: u64) {
    using player
    dt_frac_sec := deltaT_ms > 0 ? (f64(deltaT_ms) / 1000.0) : 0.0
    new_x := loc.x + (dir.x * PLAYER_MOVE_SPEED * dt_frac_sec)
    new_y := loc.y + (dir.y * PLAYER_MOVE_SPEED * dt_frac_sec)

    new_x = clamp(new_x, 0, W_WIDTH - f64(sprite.w))
    new_y = clamp(new_y, 0, W_HEIGHT - f64(sprite.h))
    
    loc.x = new_x
    loc.y = new_y
}

GetPlayerBoundingBox :: proc(player: ^Player) -> BoundingBox {
    using player
    return BoundingBox{
        i32(loc.x),
        i32(loc.y),
        sprite.w,
        sprite.h,
    }
}