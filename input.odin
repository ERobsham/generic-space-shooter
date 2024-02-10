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
    .East = LEFT_KEYS,
    .South = DOWN_KEYS,
    .West = RIGHT_KEYS,
}

GetMovementVec :: proc(keyboard_state : [^]u8) -> Vec2 {
    move_vec := MoveVecForDir[MoveDir.Stationary]

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
            move_vec.x += dir_vec.x
            move_vec.y += dir_vec.y
        }
    } 

    return move_vec
}