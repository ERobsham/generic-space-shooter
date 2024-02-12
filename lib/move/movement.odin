package move

import "core:math"
import "core:math/rand"

SQRT2 :: math.SQRT_TWO

Vec2 :: struct {
    x,y : f64
}

Dir :: enum {
    Stationary,
    North,
    East,
    South,
    West,
    NorthEast,
    SouthEast,
    NorthWest,
    SouthWest,
}

@(private)
dirToMoveVecMap := [Dir]Vec2 {
    .Stationary = {  0,          0       },
    .North      = {  0,         -1       },
    .NorthEast  = { +1/SQRT2,   -1/SQRT2 },
    .East       = { +1,          0       },
    .SouthEast  = { +1/SQRT2,   +1/SQRT2 },
    .South      = {  0,         +1       },
    .SouthWest  = { -1/SQRT2,   +1/SQRT2 },
    .West       = { -1,          0       },
    .NorthWest  = { -1/SQRT2,   -1/SQRT2 },
}

dirReverseMap := [Dir]Dir {
    .Stationary = .Stationary,
    .North      = .South,
    .NorthEast  = .SouthWest,
    .East       = .West,
    .SouthEast  = .NorthWest,
    .South      = .North,
    .SouthWest  = .NorthEast,
    .West       = .East,
    .NorthWest  = .SouthEast,
}

VecFor :: proc(dir: Dir) -> Vec2 {
    move_vec := dirToMoveVecMap[dir]
    return Vec2{
        move_vec.x,
        move_vec.y,
    }
}

RandomDir :: proc() -> Dir {
    return rand.choice([]Dir{
        .Stationary, 
        .North,
        .East,
        .South,
        .West,
        .NorthEast,
        .SouthEast,
        .NorthWest,
        .SouthWest,
    })
}

ReverseDir :: proc(d: Dir) -> Dir {
    return dirReverseMap[d]
}