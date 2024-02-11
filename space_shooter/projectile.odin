package space_shooter

import "vendor:sdl2"

import "../lib"
import "../lib/move"

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
}

CreateProjectile :: proc(at: move.Vec2, dir: move.Vec2) -> Projectile {
    return Projectile{
        loc = at,
        dimensions = { PROJECTILE_SPRITE.t_w, PROJECTILE_SPRITE.t_h },
        
        dir = dir,
        speed = PROJECTILE_SPEED,

        sprite = PROJECTILE_SPRITE,

        update = proc(self: ^lib.GameObject, dt: f64) {
            UpdateProjectile(cast(^Projectile)self, dt)
        },
        draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
            DrawProjectile(cast(^Projectile)self, renderer)
        },
    }
}


UpdateProjectile :: proc(proj:^Projectile, dt: f64) {
    lib.Move(cast(^lib.GameObject)proj, dt)
}

DrawProjectile :: proc(proj:^Projectile, renderer: ^sdl2.Renderer) {
    using proj
    
    if destroyed do return

    DrawSprite(renderer, 
        sprite, 
        lib.GetBoundingBox(cast(^lib.GameObject)proj),
    )
}
