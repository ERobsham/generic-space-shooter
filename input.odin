package main

import "vendor:sdl2"


UP_KEYS :: []sdl2.Scancode{
    sdl2.Scancode.UP,
    sdl2.Scancode.W,
}
RIGHT_KEYS :: []sdl2.Scancode{
    sdl2.Scancode.RIGHT,
    sdl2.Scancode.D,
}
DOWN_KEYS :: []sdl2.Scancode{
    sdl2.Scancode.DOWN,
    sdl2.Scancode.S,
}
LEFT_KEYS :: []sdl2.Scancode{
    sdl2.Scancode.LEFT,
    sdl2.Scancode.A,
}

MovementKeys := #partial [MoveDir][]sdl2.Scancode {
    .North = UP_KEYS,
    .East = RIGHT_KEYS,
    .South = DOWN_KEYS,
    .West = LEFT_KEYS,
}

GetMoveDir :: proc(keyboard_state : [^]u8) -> MoveDir {
    up_down := 0
    left_right := 0
    
    for keys, dir in MovementKeys {
        dir_vec := MoveVecForDir[dir]
        any_pressed := false
        
        for key in keys {
            if keyboard_state[key] == sdl2.PRESSED {
                any_pressed = true
                break
            }
        }
        
        if any_pressed {
            left_right += int(dir_vec.x)
            up_down += int(dir_vec.y)
        }
    }
    
    switch {
        case up_down == 0 && left_right == 0:
            return MoveDir.Stationary
        
        case up_down < 0 && left_right == 0:
            return MoveDir.North
        case up_down > 0 && left_right == 0:
            return MoveDir.South
        case up_down == 0 && left_right > 0:
            return MoveDir.East
        case up_down == 0 && left_right < 0:
            return MoveDir.West

        case up_down < 0 && left_right > 0:
            return MoveDir.NorthEast
        case up_down < 0 && left_right < 0:
            return MoveDir.NorthWest
        
        case up_down > 0 && left_right > 0:
            return MoveDir.SouthEast
        case up_down > 0 && left_right < 0:
            return MoveDir.SouthWest
    }

    // unreachable, but sane defaut
    return MoveDir.Stationary
}

