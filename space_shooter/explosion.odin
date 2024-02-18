package space_shooter

import "vendor:sdl2"

import "../lib"
import "../lib/physics2d"

EXPLOSION_SPRITE :: SpriteInfo {
    ss_idx = 0,
    t_col = 0,
    t_row = 7,
    t_w = 34,
    t_h = 34,
}

EXPLOSION_SPEED :: 1.0/4.0
EXPLOSION_STAGES :: 2;

Explosion :: struct {
    using gObj: lib.GameObject,
    
    sprite: SpriteInfo,

    stage: i32,
    stage_cd: f64,
}

// creates a pointer to a 'new' explosion object -- ie, must be freed.
CreateExplosionPtr :: proc(at: physics2d.Vec2) -> ^Explosion {
    e := new(Explosion)
        
    e.loc = at
    e.dimensions = { f64(EXPLOSION_SPRITE.t_w), f64(EXPLOSION_SPRITE.t_h) }
    e.loc.x -= (f64(EXPLOSION_SPRITE.t_w) / 2)
    e.loc.y -= (f64(EXPLOSION_SPRITE.t_h) / 2)
    
    e.dir = VecFor(Dir.Stationary)
    e.speed = 0

    e.sprite = EXPLOSION_SPRITE

    e.stage = 0
    e.stage_cd = EXPLOSION_SPEED

    e.update = proc(self: ^lib.GameObject, dt: f64) {
        UpdateExplosion(cast(^Explosion)self, dt)
    }
    e.draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
        DrawExplosion(cast(^Explosion)self, renderer)
    }

    PlayEffect(.Explosion)
    
    return e
}

UpdateExplosion :: proc(explosion:^Explosion, dt: f64) {
    using explosion

    stage_cd -= dt
    if stage_cd <= 0 {
        stage += 1
        stage_cd = EXPLOSION_SPEED
    }

    if stage > EXPLOSION_STAGES {
        destroyed = true
    }
}

DrawExplosion :: proc(explosion:^Explosion, renderer: ^sdl2.Renderer) {
    using explosion
    
    if destroyed do return

    DrawSprite(renderer, 
        SpriteInfo{
            sprite.ss_idx,
            sprite.t_col + stage,
            sprite.t_row,
            sprite.t_w,
            sprite.t_h,
        }, 
        lib.GetBoundingBox(cast(^lib.GameObject)explosion),
    )
}
