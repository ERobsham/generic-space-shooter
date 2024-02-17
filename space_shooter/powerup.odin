package space_shooter

import "core:fmt"
import "vendor:sdl2"

import "../lib"
import "../lib/move"
import "../lib/collision"

POWERUP_SPRITE_Multishot :: SpriteInfo {
    ss_idx = 0,
    t_col = 0,
    t_row = 6,
    t_w = 23,
    t_h = 11,
}
POWERUP_SPRITE_ShotSpeed :: SpriteInfo {
    ss_idx = 0,
    t_col = 1,
    t_row = 6,
    t_w = 23,
    t_h = 11,
}
POWERUP_SPRITE_RateOfFire :: SpriteInfo {
    ss_idx = 0,
    t_col = 2,
    t_row = 6,
    t_w = 23,
    t_h = 11,
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

CreatePowerup :: proc(at: move.Vec2, type: PowerupType) -> Powerup {
    sprite := powerupSpriteByType[type]
    
    p := Powerup{
        loc = at,
        dimensions = { sprite.t_w, sprite.t_h },
        
        dir = move.VecFor(move.Dir.South),
        speed = POWERUP_SPEED,
        
        type = type,

        update = proc(self: ^lib.GameObject, dt: f64) {
            UpdatePowerup(cast(^Powerup)self, dt)
        },
        draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
            DrawPowerup(cast(^Powerup)self, renderer)
        },
    }

    p.loc.x -= (f64(p.dimensions.w) / 2)
    p.loc.y -= (f64(p.dimensions.h) / 2)

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

ApplyPowerupToPlayer :: proc(player: ^Player, powerup: PowerupType) {
    switch powerup {
        case .Multishot: {
            if player.multi_shot == 0 {
                player.multi_shot += 1
            }
            else {
                player.multi_shot = 
                    clamp(player.multi_shot + 2, 0, PLAYER_MULITI_SHOT_MAX-1)
            }
        }
        case .ShotSpeed: {
            player.shot_speed_mod =
                clamp(player.shot_speed_mod + 0.2, 1.0, 3.0)
        }
        case .RateOfFire: {
            player.rof_mod =
                clamp(player.rof_mod + 0.2, 1.0, 5.0)
        }
    }
}
