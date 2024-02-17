package physics2d

import "core:math"

Vec2 :: struct {
    x,y : f64
}

VecLength :: proc(vec: Vec2) -> f64 {
    x_sq := vec.x * vec.x
    y_sq := vec.y * vec.y
    return  x_sq + y_sq / math.sqrt_f64(x_sq + y_sq)
}

VecNormalize :: proc(vec: Vec2) -> Vec2 {
    length := VecLength(vec)
    return Vec2 {
        vec.x / length,
        vec.y / length,
    }
}
