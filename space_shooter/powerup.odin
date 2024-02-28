package space_shooter

import "core:fmt"
import "vendor:sdl2"

import "../lib"
import "../lib/physics2d"

POWERUP_W   :: 42
POWERUP_H   :: 42
POWERUP_ROW :: 5
POWERUP_COL :: 0

POWERUP_SPRITE_Multishot :: SpriteInfo {
    ss_idx = 0,
    t_col  = POWERUP_COL + 0,
    t_row  = POWERUP_ROW,
    t_w    = POWERUP_W,
    t_h    = POWERUP_H,
}
POWERUP_SPRITE_ShotSpeed :: SpriteInfo {
    ss_idx = 0,
    t_col  = POWERUP_COL + 1,
    t_row  = POWERUP_ROW,
    t_w    = POWERUP_W,
    t_h    = POWERUP_H,
}
POWERUP_SPRITE_RateOfFire :: SpriteInfo {
    ss_idx = 0,
    t_col  = POWERUP_COL + 2,
    t_row  = POWERUP_ROW,
    t_w    = POWERUP_W,
    t_h    = POWERUP_H,
}
POWERUP_SPEED :: 100.0

PowerupType :: enum {
    Multishot,
    ShotSpeed,
    RateOfFire,
    // PunchThrough,
}

powerupSpriteByType := [PowerupType]SpriteInfo {
    .Multishot = POWERUP_SPRITE_Multishot,
    .ShotSpeed = POWERUP_SPRITE_ShotSpeed,
    .RateOfFire = POWERUP_SPRITE_RateOfFire,
}

powerupTypes := []PowerupType {
    PowerupType.Multishot,
    PowerupType.ShotSpeed,
    PowerupType.RateOfFire,
};

Powerup :: struct {
    using gObj: lib.GameObject,

    type: PowerupType,
}

CreatePowerup :: proc(at: physics2d.Vec2, type: PowerupType) -> Powerup {
    sprite := powerupSpriteByType[type]
    
    p := Powerup{
        loc = at,
        dimensions = { f64(sprite.t_w), f64(sprite.t_h) },
        
        dir = VecFor(Dir.South),
        speed = POWERUP_SPEED,
        
        type = type,

        update = proc(self: ^lib.GameObject, dt: f64) {
            UpdatePowerup(cast(^Powerup)self, dt)
        },
        draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
            DrawPowerup(cast(^Powerup)self, renderer)
        },
    }

    p.loc.x -= p.dimensions.w / 2
    p.loc.y -= p.dimensions.h / 2

    return p
}

UpdatePowerup :: proc(powerup:^Powerup, dt: f64) {
    lib.Move(cast(^lib.GameObject)powerup, dt)

    window_bounds := (cast(^SpaceShooterAPI)powerup.api)->windowBB()
    bb := lib.GetBoundingBox(cast(^lib.GameObject)powerup)
    if !bb->isColliding(window_bounds) {
        // we're outside the window bounds. dispose of this
        powerup.destroyed = true
    }
}

DrawPowerup :: proc(powerup:^Powerup, renderer: ^sdl2.Renderer) {
    using powerup
    
    if destroyed do return
    
    sprite := powerupSpriteByType[type]
    DrawSprite(renderer, 
        sprite, 
        lib.GetBoundingBox(cast(^lib.GameObject)powerup),
    )
}
