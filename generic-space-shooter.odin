package main

import "core:c"
import "vendor:sdl2"
import "vendor:sdl2/image"
import "vendor:sdl2/mixer"

import "lib/deltaT"
import "lib/physics2d"

import "space_shooter"

R_FLAGS :: (sdl2.RENDERER_ACCELERATED | sdl2.RENDERER_PRESENTVSYNC)

main :: proc() {

    sdl2.Init({})
    defer sdl2.Quit()

    image.Init(image.INIT_PNG)
    defer image.Quit()

    mixer.Init(mixer.INIT_FLAC)
    defer mixer.Quit()
    
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

    menu := InitMenu(renderer)
    defer DestroyMenu(menu)

    deltaT.Init()

    event: sdl2.Event
    loop: 
    for {
        // process exit events
        sdl2.PollEvent(&event)
        if event.type == sdl2.EventType.QUIT do return
        
        dt := deltaT.Get()
        
        UpdateMenu(menu, &event, dt)

        if menu.current_menu == .None {
            ProcessKeyboardInput(game_state)
        }
        
        if menu.current_menu != .Pause &&
            menu.current_menu != .Main {
            // process game step
            UpdateGameState(game_state, dt)
            if IsGameOver(game_state) do menu.current_menu = .GameOver
        }

        if menu.current_menu == .Main &&
            menu.is_transistion {
            ResetGameState(game_state)
        }
        
        ClearRender(renderer)
        
        if menu.current_menu != .Main {

            // draw the new state
            DrawGameState(game_state, renderer)
        }
        DrawMenu(menu, renderer)

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
