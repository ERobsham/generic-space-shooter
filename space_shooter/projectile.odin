package space_shooter

import "core:fmt"
import "vendor:sdl2"

import "../lib"
import "../lib/physics2d"

PROJECTILE_SPRITE :: SpriteInfo {
    ss_idx = 0,
    t_col = 0,
    t_row = 4,
    t_w = 3,
    t_h = 12,
}

PROJECTILE_SPEED :: 600.0

Projectile :: struct {
    using gObj: lib.GameObject,
    
    sprite: SpriteInfo,

    is_friendly: bool,
}

CreateProjectile :: proc(at: physics2d.Vec2, dir: physics2d.Vec2, is_friendly: bool = true) -> Projectile {
    p := Projectile{
        loc = at,
        dimensions = { f64(PROJECTILE_SPRITE.t_w), f64(PROJECTILE_SPRITE.t_h) },
        
        dir = dir,
        speed = PROJECTILE_SPEED,

        sprite = PROJECTILE_SPRITE,

        update = proc(self: ^lib.GameObject, dt: f64) {
            UpdateProjectile(cast(^Projectile)self, dt)
        },
        draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
            DrawProjectile(cast(^Projectile)self, renderer)
        },

        is_friendly = is_friendly,
    }

    if !is_friendly {
        p.sprite.t_col += 1
    }

    return p
}

UpdateProjectile :: proc(proj:^Projectile, dt: f64) {
    lib.Move(cast(^lib.GameObject)proj, dt)

    window_bounds := (cast(^SpaceShooterAPI)proj.api)->windowBB()
    bb := lib.GetBoundingBox(cast(^lib.GameObject)proj)
    if !bb->isColliding(window_bounds) {
        // we're outside the window bounds. dispose of this
        proj.destroyed = true
    }
}

DrawProjectile :: proc(proj:^Projectile, renderer: ^sdl2.Renderer) {
    using proj
    
    if destroyed do return

    DrawSprite(renderer, 
        sprite, 
        lib.GetBoundingBox(cast(^lib.GameObject)proj),
    )
}
