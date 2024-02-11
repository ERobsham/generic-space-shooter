package space_shooter

import "vendor:sdl2"

import "../lib"

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
