package lib

import "vendor:sdl2"

import "collision"
import "move"

GameObject :: struct {
    update: proc(self: ^GameObject, dt: f64),
    draw: proc(self: ^GameObject, renderer: ^sdl2.Renderer),
    api: ^GameStateAPI,
    
    loc: move.Vec2,
    dimensions: struct { w, h: i32 },
    
    // target move speed in px/sec
    speed: u32,
    dir: move.Vec2,
    
    disabled: bool,
    destroyed: bool,
}

MoveWithin :: proc(gObj: ^GameObject, within: collision.BoundingBox, dt: f64) {
    using gObj
    
    new_x := loc.x + (dir.x * f64(speed) * dt)
    new_y := loc.y + (dir.y * f64(speed) * dt)

    new_x = clamp(new_x, f64(within.x), f64(within.w - dimensions.w))
    new_y = clamp(new_y, f64(within.y), f64(within.h - dimensions.h))
    
    loc.x = new_x
    loc.y = new_y
}

Move :: proc(gObj: ^GameObject, dt: f64) {
    using gObj

    loc.x = loc.x + (dir.x * f64(speed) * dt)
    loc.y = loc.y + (dir.y * f64(speed) * dt)
}

GetBoundingBox :: proc(gObj: ^GameObject) -> collision.BoundingBox {
    using gObj
    return collision.BoundingBox{
        i32(loc.x),
        i32(loc.y),
        dimensions.w,
        dimensions.h,
    }
}