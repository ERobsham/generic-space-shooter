package main

import "core:c"
import "core:fmt"
import "vendor:sdl2"
import "vendor:sdl2/image"

W_TITLE    :: "Hello World"
W_ORIGIN_X :: sdl2.WINDOWPOS_CENTERED
W_ORIGIN_Y :: sdl2.WINDOWPOS_CENTERED
W_WIDTH    :: 1024
W_HEIGHT   :: 768
W_FLAGS    :: (sdl2.WINDOW_INPUT_FOCUS|sdl2.WINDOW_MOUSE_FOCUS)

R_FLAGS :: (sdl2.RENDERER_ACCELERATED | sdl2.RENDERER_PRESENTVSYNC)

WindowBB := BoundingBox {
    0,0,
    W_WIDTH, W_HEIGHT,
}

main :: proc() {

    sdl2.Init({})
    defer sdl2.Quit()

    image.Init(image.INIT_PNG)
    defer image.Quit()
    
    window := sdl2.CreateWindow(W_TITLE, W_ORIGIN_X, W_ORIGIN_Y, W_WIDTH, W_HEIGHT, W_FLAGS)
    assert(window != nil, "cannot create window")
    defer sdl2.DestroyWindow(window)

    renderer := sdl2.CreateRenderer(window, 0, R_FLAGS)
    assert(renderer != nil, "cannit get renderer")
    defer sdl2.DestroyRenderer(renderer)

    InitSpriteSheet(renderer)
    defer DestroySpriteSheet()

    player := NewPlayer(renderer)

    last_timestamp := sdl2.GetPerformanceCounter() / (sdl2.GetPerformanceFrequency() / 1000)

    event: sdl2.Event
    loop: 
    for {

        timestamp := sdl2.GetPerformanceCounter() / (sdl2.GetPerformanceFrequency() / 1000)
        dt_ms := timestamp - last_timestamp
        last_timestamp = timestamp


        // get keyboard state
        key_states := sdl2.GetKeyboardState(nil)
        
        // get mouse state
        mX, mY : c.int
        mouse_state := sdl2.GetMouseState(&mX, &mY)
        mouse_x := i32(mX)
        mouse_y := i32(mY)

        // process events
        move_dir := MoveDir.Stationary
        {
            using sdl2.EventType
            
            sdl2.PollEvent(&event)
            #partial switch event.type {
                case KEYDOWN, KEYUP:
                    move_dir = GetMoveDir(key_states)
                    player.dir = MoveVecForDir[move_dir]
                    fmt.println("move dir: ", move_dir, "  dt: ", dt_ms)
                
                // case MOUSEBUTTONDOWN, MOUSEBUTTONUP:
                //     fmt.println("mouse event: ", event.button)
                    
                case sdl2.EventType.QUIT:
                    fmt.println("exit event")
                    return
            }
        }
        
        ClearRender(renderer)
        
        // process game step
        MovePlayer(&player, dt_ms)

        // render the things
        DrawPlayer(&player, renderer)
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
