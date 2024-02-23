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
EXPLOSION_STAGES :: 3;

Explosion :: struct {
    using gObj: lib.GameObject,
    sprite: AnimatedSprite,
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

    e.sprite = NewAnimiatedSprite(EXPLOSION_SPRITE, EXPLOSION_STAGES, EXPLOSION_SPEED, false)

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

    sprite->update(dt)

    if sprite.current_frame == EXPLOSION_STAGES-1 {
        destroyed = true
    }
}

DrawExplosion :: proc(explosion:^Explosion, renderer: ^sdl2.Renderer) {
    using explosion
    
    if destroyed do return

    sprite->draw(renderer, lib.GetBoundingBox(cast(^lib.GameObject)explosion))
}
