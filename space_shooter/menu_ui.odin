package space_shooter

import "vendor:sdl2"
import "vendor:sdl2/image"

BLINK_CD :: 2.0
IS_BLINKED_CD :: .5

TitleW :: 360
TitleH :: 106

PauseW :: 153
PauseH :: 39

GameOverW :: 279
GameOverH :: 47

PressAnyKeyW :: 123
PressAnyKeyH :: 23

PressEscKeyW :: 181
PressEscKeyH :: 18



Menu :: struct {
    current_menu  : MenuState,
    is_transistion: bool,

    blink_cd  : f64,
    is_blinked: bool,

    main_menu_text: ^sdl2.Texture,
    pause_text: ^sdl2.Texture,
    game_over_text: ^sdl2.Texture,
    press_any_key_test: ^sdl2.Texture,
    press_esc_key_test: ^sdl2.Texture,
}

MenuState :: enum {
    None,
    Pause,
    Main,
    GameOver,
}

InitMenu :: proc(renderer: ^sdl2.Renderer) -> ^Menu {
    m := new(Menu)

    m.current_menu = .Main
    m.blink_cd = BLINK_CD
    m.is_blinked = false
    
    tex := image.LoadTexture(renderer, "assets/MainMenuText.png")
    assert(tex != nil, "unable to load MainMenu texture")
    m.main_menu_text = tex

    tex = image.LoadTexture(renderer, "assets/PauseMenuText.png")
    assert(tex != nil, "unable to load PauseMenu texture")
    m.pause_text = tex
    
    tex = image.LoadTexture(renderer, "assets/GameOverText.png")
    assert(tex != nil, "unable to load GameOver texture")
    m.game_over_text = tex

    tex = image.LoadTexture(renderer, "assets/PressAnyKey.png")
    assert(tex != nil, "unable to load PressAnyKey texture")
    m.press_any_key_test = tex

    tex = image.LoadTexture(renderer, "assets/PressEscKey.png")
    assert(tex != nil, "unable to load PressEscKey texture")
    m.press_esc_key_test = tex

    return m
}

DestroyMenu :: proc(m: ^Menu) {

    sdl2.DestroyTexture(m.main_menu_text)
    sdl2.DestroyTexture(m.pause_text)
    sdl2.DestroyTexture(m.game_over_text)

    free(m)
}

UpdateMenu :: proc(m: ^Menu, event: ^sdl2.Event, dt: f64) {
    m.is_transistion = false
    init_menu := m.current_menu
    switch m.current_menu {
        case .None: {
            if event.type == sdl2.EventType.KEYUP && 
                event.key.keysym.scancode == sdl2.SCANCODE_ESCAPE {
                // immedately pause on `esc` key presses
                m.current_menu = .Pause
            }
        }
        case .Pause: {
            if event.type == sdl2.EventType.KEYUP && 
                event.key.keysym.scancode == sdl2.SCANCODE_ESCAPE {
                // immedately pause on `esc` key presses
                m.current_menu = .None
            }
        }
        case .Main: {
            if event.type == sdl2.EventType.KEYUP ||
                event.type == sdl2.EventType.MOUSEBUTTONUP {
                // any button / key up event should start the game
                m.current_menu = .None
            }
        }
        case .GameOver: {
            if event.type == sdl2.EventType.KEYUP && 
            event.key.keysym.scancode == sdl2.SCANCODE_ESCAPE {
                // any button / key up event should start the game
                m.current_menu = .Main
            }
        }
    }

    if m.current_menu != init_menu {
        m.is_transistion = true
        m.blink_cd = BLINK_CD
    } 
    if m.current_menu == .None do return

    m.blink_cd -= dt
    if m.blink_cd <= 0 {
        m.is_blinked = !m.is_blinked
        m.blink_cd = m.is_blinked ? IS_BLINKED_CD : BLINK_CD
    }
}

DrawMenu :: proc(m: ^Menu, renderer: ^sdl2.Renderer) {
    
    switch m.current_menu {
        case .None: {
            return
        }
        case .Pause: {
            // draw a pause overlay
            drawMenuCentered(renderer, m.pause_text, PauseW, PauseH)
            
            if (!m.is_blinked) {
                drawMenuCentered(renderer, m.press_esc_key_test, PressEscKeyW, PressEscKeyH, 1.5)
            }
        }
        case .Main: {
            // draw a 'main menu' screen
            drawMenuCentered(renderer, m.main_menu_text, TitleW, TitleH)

            if (!m.is_blinked) {
                drawMenuCentered(renderer, m.press_any_key_test, PressAnyKeyW, PressAnyKeyH, 1.5)
            }
        }
        case .GameOver: {
            // draw a 'game over' screen
            drawMenuCentered(renderer, m.game_over_text, GameOverW, GameOverH)

            if (!m.is_blinked) {
                drawMenuCentered(renderer, m.press_esc_key_test, PressEscKeyW, PressEscKeyH, 1.5)
            }
        }
    }
}

@(private="file")
drawMenuCentered :: proc(renderer: ^sdl2.Renderer, texture: ^sdl2.Texture, w: i32, h:i32, y_offset: f64 = 0.5) {
    center := WindowBB->getCenter()
    
    
    x := i32(center.x - f64(w / 2))
    y := i32((center.y * y_offset) - f64(h / 2))
    src := sdl2.Rect{ 
        0, 0,
        w, h,
    }
    dest := sdl2.Rect{ 
        x, y,
        w, h,
    }

    sdl2.RenderCopy(renderer, texture, &src, &dest)
}