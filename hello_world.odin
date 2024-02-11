package main

import "core:c"
import "vendor:sdl2"
import "vendor:sdl2/image"

import "lib/deltaT"

import "space_shooter"

R_FLAGS :: (sdl2.RENDERER_ACCELERATED | sdl2.RENDERER_PRESENTVSYNC)

main :: proc() {

    sdl2.Init({})
    defer sdl2.Quit()

    image.Init(image.INIT_PNG)
    defer image.Quit()
    
    window := sdl2.CreateWindow(
        space_shooter.W_TITLE, 
        space_shooter.W_ORIGIN_X, 
        space_shooter.W_ORIGIN_Y, 
        space_shooter.W_WIDTH, 
        space_shooter.W_HEIGHT, 
        space_shooter.W_FLAGS,
    )
    assert(window != nil, "cannot create window")
    defer sdl2.DestroyWindow(window)

    renderer := sdl2.CreateRenderer(window, 0, R_FLAGS)
    assert(renderer != nil, "cannit get renderer")
    defer sdl2.DestroyRenderer(renderer)

    using space_shooter
    game_state := InitGameState(window, renderer)
    defer DestroyGameState(game_state)

    deltaT.Init()

    event: sdl2.Event
    loop: 
    for {
        // process exit events
        sdl2.PollEvent(&event)
        if event.type == sdl2.EventType.QUIT do return


        ProcessKeyboardInput(game_state)
        
        // process game step
        dt := deltaT.Get()
        UpdateGameState(game_state, dt)

        // draw the new state
        ClearRender(renderer)
        DrawGameState(game_state, renderer)
        
        // for funzies to see how well mouse tracking works
        mX, mY : c.int
        sdl2.GetMouseState(&mX, &mY)
        DrawRect(renderer, i32(mX), i32(mY))

        // present the scene
        sdl2.RenderPresent(renderer)

        // any cleanup
        PostDrawCleanup(game_state)
    }
}

ClearRender :: proc(renderer: ^sdl2.Renderer) {
    sdl2.RenderClear(renderer)
    sdl2.SetRenderDrawColor(renderer, 0, 0, 0, 0)
}


// helper to draw rect around mouse
DrawRect :: proc(renderer: ^sdl2.Renderer, x: i32, y: i32) {
    sdl2.SetRenderDrawColor(renderer, 0, 0xFF, 0, 0)
    
    rect := sdl2.Rect{x-10, y-10, 20, 20}
    sdl2.RenderDrawRect(renderer, &rect)
    
    sdl2.SetRenderDrawColor(renderer, 0, 0, 0, 0)
}
