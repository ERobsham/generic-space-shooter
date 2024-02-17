package space_shooter

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

@(private="file")
movementKeys := #partial [Dir][]sdl2.Scancode {
    .North = UP_KEYS,
    .East = RIGHT_KEYS,
    .South = DOWN_KEYS,
    .West = LEFT_KEYS,
}

// expects the result of 'sdl2.GetKeyboardState(..)' as its argument
GetMoveDir :: proc(keyboard_state : [^]u8) -> Dir {
    
    up_down := 0
    left_right := 0
    for keys, dir in movementKeys {
        dir_vec := VecFor(dir)
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
            return Dir.Stationary
        
        case up_down < 0 && left_right == 0:
            return Dir.North
        case up_down > 0 && left_right == 0:
            return Dir.South
        case up_down == 0 && left_right > 0:
            return Dir.East
        case up_down == 0 && left_right < 0:
            return Dir.West

        case up_down < 0 && left_right > 0:
            return Dir.NorthEast
        case up_down < 0 && left_right < 0:
            return Dir.NorthWest
        
        case up_down > 0 && left_right > 0:
            return Dir.SouthEast
        case up_down > 0 && left_right < 0:
            return Dir.SouthWest
    }

    // unreachable, but sane defaut
    return Dir.Stationary
}

GetShootingState :: proc(keyboard_state : [^]u8) -> bool {
    // for now, just hardcode space as the only 'fire' key
    return keyboard_state[sdl2.SCANCODE_SPACE] == sdl2.PRESSED
}