package space_shooter

import "vendor:sdl2"

import "../lib"
import "../lib/physics2d"

EXPLOSION_SPRITE :: SpriteInfo {
    ss_idx = 0,
    t_col = 0,
    t_row = 6,
    t_w = 64,
    t_h = 64,
}

EXPLOSION_SPEED :: 1.0/8.0
EXPLOSION_STAGES :: 4;

Explosion :: struct {
    using gObj: lib.GameObject,
    sprite_fg: AnimatedSprite,
    sprite_bg: AnimatedSprite,
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

    e.sprite_fg = NewAnimiatedSprite(EXPLOSION_SPRITE, EXPLOSION_STAGES, EXPLOSION_SPEED, false)
    e.sprite_bg = NewAnimiatedSprite(EXPLOSION_SPRITE, EXPLOSION_STAGES, EXPLOSION_SPEED, false)
    e.sprite_bg.t_row += 1

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

    sprite_fg->update(dt)
    sprite_bg->update(dt)

    if sprite_bg.done {
        destroyed = true
    }
}

DrawExplosion :: proc(explosion:^Explosion, renderer: ^sdl2.Renderer) {
    using explosion
    
    if destroyed do return

    bb := lib.GetBoundingBox(cast(^lib.GameObject)explosion)
    sprite_bg->draw(renderer, bb)
    sprite_fg->draw(renderer, bb)
}
