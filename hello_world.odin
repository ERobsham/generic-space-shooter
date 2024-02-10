package main

import "core:c"
import "core:fmt"
import "vendor:sdl2"

W_TITLE    :: "Hello World"
W_ORIGIN_X :: sdl2.WINDOWPOS_CENTERED
W_ORIGIN_Y :: sdl2.WINDOWPOS_CENTERED
W_WIDTH    :: 1024
W_HEIGHT   :: 768
W_FLAGS    :: (sdl2.WINDOW_INPUT_FOCUS|sdl2.WINDOW_MOUSE_FOCUS)

R_FLAGS :: (sdl2.RENDERER_ACCELERATED | sdl2.RENDERER_PRESENTVSYNC)

main :: proc() {

    sdl2.Init({})
    defer sdl2.Quit()
    
    window := sdl2.CreateWindow(W_TITLE, W_ORIGIN_X, W_ORIGIN_Y, W_WIDTH, W_HEIGHT, W_FLAGS)
    assert(window != nil, "cannot create window")
    defer sdl2.DestroyWindow(window)

    renderer := sdl2.CreateRenderer(window, 0, R_FLAGS)
    assert(renderer != nil, "cannit get renderer")
    defer sdl2.DestroyRenderer(renderer)


    event: sdl2.Event
    loop: 
    for {

        // get keyboard state
        key_states := sdl2.GetKeyboardState(nil)
        
        // get mouse state
        mX, mY : c.int
        mouse_state := sdl2.GetMouseState(&mX, &mY)
        mouse_x := i32(mX)
        mouse_y := i32(mY)

        // process events
        move_vec : Vec2
        if !sdl2.PollEvent(&event) {
            continue
        }
        else {
            using sdl2.EventType
            #partial switch event.type {
                case KEYDOWN, KEYUP:
                    move_vec := GetMovementVec(key_states)
                    fmt.println("move dir: ", move_vec)
                
                case MOUSEBUTTONDOWN, MOUSEBUTTONUP:
                    fmt.println("mouse event: ", event.button)
                    
                case sdl2.EventType.QUIT:
                    fmt.println("exit event")
                    return
            }
        }
        
        ClearRender(renderer)
        
        // process game step

        // render the things
        DrawRect(renderer, mouse_x, mouse_y)

        sdl2.RenderPresent(renderer)

        // any cleanup?
    }
}

DrawRect :: proc(renderer: ^sdl2.Renderer, x: i32, y: i32) {
    sdl2.SetRenderDrawColor(renderer, 0, 0xFF, 0, 0)
    
    rect := sdl2.Rect{x-10, y-10, 20, 20}
    sdl2.RenderDrawRect(renderer, &rect)
    
    sdl2.SetRenderDrawColor(renderer, 0, 0, 0, 0)
}

ClearRender :: proc(renderer: ^sdl2.Renderer) {
    sdl2.RenderClear(renderer)
    sdl2.SetRenderDrawColor(renderer, 0, 0, 0, 0)
}
