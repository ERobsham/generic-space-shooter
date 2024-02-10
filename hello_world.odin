
package main

import "core:fmt"
import "vendor:sdl2"

TITLE :: "Hellow World"

main :: proc() {
    fmt.println("hello from odin")

    window := sdl2.CreateWindow(TITLE, 100, 100, 256, 256, {})
    if window == nil {
        fmt.eprintln("cannot create window... exiting")
        return
    }
    defer sdl2.DestroyWindow(window)

    event : sdl2.Event

    for {
        sdl2.PollEvent(&event)

        #partial switch event.type {
            case sdl2.EventType.KEYDOWN:
                fmt.println("key pressed:", event.key.keysym.scancode)
            case sdl2.EventType.KEYUP:
                fmt.println("key released:", event.key.keysym.scancode)
        }
    }
}
