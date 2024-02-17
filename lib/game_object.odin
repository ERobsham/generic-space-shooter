package lib

import "vendor:sdl2"

import "physics2d"

GameObject :: struct {
    update: proc(self: ^GameObject, dt: f64),
    draw: proc(self: ^GameObject, renderer: ^sdl2.Renderer),
    api: ^GameStateAPI,
    
    loc: physics2d.Vec2,
    dimensions: physics2d.Dim2,
    
    // target move speed in px/sec
    speed: u32,
    // normalized direction vector
    dir: physics2d.Vec2,
    
    disabled: bool,
    destroyed: bool,
}

MoveWithin :: proc(gObj: ^GameObject, within: physics2d.BoundingBox, dt: f64) {
    using gObj
    
    new_x := loc.x + (dir.x * f64(speed) * dt)
    new_y := loc.y + (dir.y * f64(speed) * dt)

    new_x = clamp(new_x, within.origin.x, within.dimensions.w - dimensions.w)
    new_y = clamp(new_y, within.origin.y, within.dimensions.h - dimensions.h)
    
    loc.x = new_x
    loc.y = new_y
}

Move :: proc(gObj: ^GameObject, dt: f64) {
    using gObj

    loc.x = loc.x + (dir.x * f64(speed) * dt)
    loc.y = loc.y + (dir.y * f64(speed) * dt)
}

GetBoundingBox :: proc(gObj: ^GameObject) -> physics2d.BoundingBox {
    using gObj
    return physics2d.NewBoundingBox(
        loc.x,
        loc.y,
        dimensions.w,
        dimensions.h,
    )
}