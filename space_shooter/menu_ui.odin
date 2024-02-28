package space_shooter

import "core:fmt"
import "core:math"
import "vendor:sdl2"
import "vendor:sdl2/image"

import im "shared:odin-imgui"
import "shared:odin-imgui/imgui_impl_sdl2"
import "shared:odin-imgui/imgui_impl_sdlrenderer2"

MENU_FLAGS :: im.WindowFlags{
    .NoTitleBar,
    .NoResize,
    .NoMove,
    .NoScrollbar,
    .NoScrollWithMouse,
    .NoCollapse,
    .NoBackground,
    .NoSavedSettings,
}

HUD_FLAGS  :: MENU_FLAGS | im.WindowFlags{
    .NoNavInputs,
    .NoNavFocus,
    .NoMouseInputs,
}

BLINK_CD :: 2.0
IS_BLINKED_CD :: .5

Menu :: struct {
    current_menu  : MenuState,
    is_transistion: bool,

    blink_cd  : f64,
    is_blinked: bool,

    game_state: ^GameState,


    // currently unused...
    title_font: ^im.Font,
    menu_font: ^im.Font,
}

MenuState :: enum {
    None,
    Pause,
    Main,
    GameOver,
}

InitMenu :: proc(window: ^sdl2.Window, renderer: ^sdl2.Renderer, game_state: ^GameState) -> ^Menu {
    
    im.CHECKVERSION()
	im.CreateContext()
	io := im.GetIO()
	io.ConfigFlags += {.NavEnableKeyboard, .NavEnableGamepad}
    im.StyleColorsDark()
    
    
    fa := io.Fonts
    menu_font  := im.FontAtlas_AddFontFromFileTTF(fa, "assets/Anta/Anta-Regular.ttf", 32.0)
    title_font := im.FontAtlas_AddFontFromFileTTF(fa, "assets/Anta/Anta-Regular.ttf", 72.0)
    im.FontAtlas_Build(fa)

    imgui_impl_sdl2.InitForSDLRenderer(window, renderer)
	imgui_impl_sdlrenderer2.Init(renderer)
    
    m := new(Menu)

    m.current_menu = .Main
    m.blink_cd = BLINK_CD
    m.is_blinked = false

    m.game_state = game_state

    m.title_font = title_font
    m.menu_font  = menu_font

    return m
}

DestroyMenu :: proc(m: ^Menu) {
    free(m)

	imgui_impl_sdlrenderer2.Shutdown()
    imgui_impl_sdl2.Shutdown()
    im.DestroyContext()
}

ProcessEventMenu :: proc(m: ^Menu, event: ^sdl2.Event) {
    imgui_impl_sdl2.ProcessEvent(event)
}

UpdateMenu :: proc(m: ^Menu, dt: f64) {
    if m.current_menu == .None do return

    m.blink_cd -= dt
    if m.blink_cd <= 0 {
        m.is_blinked = !m.is_blinked
        m.blink_cd = m.is_blinked ? IS_BLINKED_CD : BLINK_CD
    }
}

DrawMenu :: proc(m: ^Menu, renderer: ^sdl2.Renderer) {
    imgui_impl_sdlrenderer2.NewFrame()
    imgui_impl_sdl2.NewFrame()
    im.NewFrame()

    drawHUD(m)
    drawMainMenu(m)
    drawPause(m)
    drawGameOver(m)

    im.Render()
    imgui_impl_sdlrenderer2.RenderDrawData(im.GetDrawData())
}

@(private="file")
drawMainMenu :: proc(m: ^Menu) {
    if m.current_menu != .Main do return

    im.Begin("main_menu", nil, MENU_FLAGS) 
    {
        im.SetWindowPos(im.Vec2{0,0})
        im.SetWindowSize(im.Vec2{W_WIDTH,W_HEIGHT})
        
        im.SetCursorPosY(200)
        
        im.PushFont(m.title_font)
        {
            Title1 :: "Generic"
            Title2 :: "Space Shooter"

            alignPosFor(Title1)
            im.TextColored({1.0,1.0,1.0,1.0}, Title1)
            
            alignPosFor(Title2)
            im.TextColored({1.0,0.0,0.0,1.0}, Title2)
        }
        im.PopFont()

        cur_y := im.GetCursorPosY()
        im.SetCursorPosY(cur_y+100)
        
        im.PushStyleColorImVec4(.Button, {0.0, 0.0, 0.0, 0.0})
        im.PushStyleColorImVec4(.ButtonHovered, {1.0, 0.0, 0.0, 0.5})
        im.PushStyleColorImVec4(.ButtonActive, {1.0, 0.0, 0.0, 0.9})
        im.PushFont(m.menu_font)
        {
            StartButton :: "Start"
            alignPosFor(StartButton)
            if im.IsWindowAppearing() do im.SetKeyboardFocusHere()
            if im.Button(StartButton) {
                fmt.println(StartButton)
                m.current_menu = .None
            }
            im.SetItemDefaultFocus()
            
            HighScores  :: "Highscores"
            alignPosFor(HighScores)
            if im.Button(HighScores) {
                fmt.println(HighScores)
            }
            
            QuitButton  :: "Quit"
            alignPosFor(QuitButton)
            if im.Button(QuitButton) {
                fmt.println(QuitButton)
                e := sdl2.Event{type = .QUIT}
                sdl2.PushEvent(&e)
            }
        }
        im.PopStyleColor(3)
        im.PopFont()

    }
    im.End()
    
}

@(private="file")
drawHUD :: proc(m: ^Menu) {
    score_w :: f32(W_WIDTH)
    score_h :: f32(W_HEIGHT*0.2)

    if m.current_menu == .Main do return
    style := im.GetStyle()

    im.Begin("score_hud", nil, HUD_FLAGS) 
    {
        im.SetWindowPos({0,0})
        im.SetWindowSize({score_w,score_h})

        alignPosFor("000000000000")
        im.TextColored({1.0,0.9,0.5,1.0},"%012d", m.game_state.score)
    }
    im.End()

    im.Begin("powerup_hud", nil, HUD_FLAGS) 
    {
        im.SetWindowFontScale(.5)
        defer im.SetWindowFontScale(1.0)
        
        lineHeight := im.GetTextLineHeightWithSpacing()
        im.SetWindowPos({0, 0})
        im.SetWindowSize({score_w * .2, W_HEIGHT})

        im.SetCursorPosY(W_HEIGHT - (lineHeight * 3.125))
        
        
        frac := f32(m.game_state.player.multi_shot) / f32(PLAYER_MULITISHOT_MAX-1)
        progressBar(frac, fmt.ctprintf("Multishot: %d", m.game_state.player.multi_shot))

        frac = f32(m.game_state.player.shot_speed_mod-1) / f32(PLAYER_SHOTSPEED_MAX-1)
        progressBar(frac, fmt.ctprintf("ProjSpeed: %0.2f", m.game_state.player.shot_speed_mod))
        
        frac = f32(m.game_state.player.rof_mod-1) / f32(PLAYER_ROF_MAX-1)
        progressBar(frac, fmt.ctprintf("RateOfFire: %0.2f", m.game_state.player.rof_mod))
    }
    im.End()

    lineHeight := im.GetTextLineHeightWithSpacing()
    im.SetNextWindowSize({f32(m.game_state.player.dimensions.w) + style.FramePadding.x*2, lineHeight})
    im.Begin("energy_hud", nil, HUD_FLAGS) 
    {
        im.SetWindowFontScale(.5)
        defer im.SetWindowFontScale(1.0)
        
        // lineHeight := im.GetTextLineHeightWithSpacing()
        im.SetCursorScreenPos({
            f32(m.game_state.player.loc.x + m.game_state.player.dimensions.w) - style.FramePadding.x, 
            f32(m.game_state.player.loc.y + (m.game_state.player.dimensions.h * 2)),
        })
        
        frac := f32(m.game_state.player.energy) / f32(m.game_state.player.energy_max)
        progressBar(frac, fmt.ctprintf("%04.2f", m.game_state.player.energy))
    }
    im.End()

    // more hud elements?
}

@(private="file")
drawPause :: proc(m: ^Menu) {
    if m.current_menu == .None &&
        (im.IsKeyReleased(.Escape) || im.IsKeyReleased(.GamepadStart)) {
        fmt.println("Pause")
        m.current_menu = .Pause
    }
    else if m.current_menu == .Pause &&
        (im.IsKeyReleased(.Escape) || im.IsKeyReleased(.GamepadStart) || 
        im.IsKeyReleased(.Enter) || im.IsKeyReleased(.GamepadFaceDown) ||
        im.IsKeyReleased(.Space) || im.IsKeyReleased(.GamepadR1)) {
        fmt.println("Unpause")
        m.current_menu = .None
    }

    if m.current_menu != .Pause do return

    im.Begin("pause_overlay", nil, HUD_FLAGS) 
    {
        im.SetWindowPos(im.Vec2{0,0})
        im.SetWindowSize(im.Vec2{W_WIDTH,W_HEIGHT})

        im.SetCursorPosY(300)

        im.PushFont(m.title_font)
        {
            Title :: "Pause"
            alignPosFor(Title)
            im.TextColored({1.0,1.0,1.0,1.0}, Title)
        }
        im.PopFont()
    }
    im.End()
}

@(private="file")
drawGameOver :: proc(m: ^Menu) {
    if m.current_menu != .GameOver do return

    if im.IsKeyReleased(.Escape) || im.IsKeyReleased(.GamepadStart) || 
        im.IsKeyReleased(.Enter) || im.IsKeyReleased(.GamepadFaceDown) {
        fmt.println("Back to Main Menu")
        ResetGameState(m.game_state)
        m.current_menu = .Main
        return
    }

    im.Begin("game_over_overlay", nil, HUD_FLAGS) 
    {
        im.SetWindowPos(im.Vec2{0,0})
        im.SetWindowSize(im.Vec2{W_WIDTH,W_HEIGHT})

        im.SetCursorPosY(300)

        im.PushFont(m.title_font)
        {
            Title :: "Game Over"
            alignPosFor(Title)
            im.TextColored({1.0,1.0,1.0,1.0}, Title)
        }
        im.PopFont()
    }
    im.End()
}

@(private="file")
alignPosFor :: proc(str: cstring, alignment: f32 = 0.5) {
    style := im.GetStyle();
    size  := im.CalcTextSize(str).x + style.FramePadding.x * 2.0;
    avail := im.GetContentRegionAvail().x;

    offset := (avail - size) * alignment;
    if offset > 0.0 do im.SetCursorPosX(im.GetCursorPosX() + offset);
}

// auto-fills container, and displays overlay on top of the  
@(private="file")
progressBar :: proc(fraction: f32, overlay: cstring) {

    style := im.GetStyle()
    // containerMin := im.GetContentRegionAvail()
    containerMax := im.GetContentRegionMax()
    lineHeight := im.GetTextLineHeightWithSpacing()
    cursorPos := im.GetCursorPos()
    padding := style.FramePadding.y
    

    sizeMin := [2]f32{ cursorPos.x, cursorPos.y }
    sizeMax := [2]f32{ sizeMin.x + containerMax.x - padding, sizeMin.y + lineHeight - padding }

    // Render

    
    // bg
    bg := im.GetBackgroundDrawList()
    im.DrawList_AddRectFilled(bg, sizeMin, sizeMax, im.GetColorU32(im.Col.FrameBg))
    im.DrawList_AddText(bg, {sizeMin.x + padding, sizeMin.y}, im.GetColorU32(im.Col.Text), overlay)
    

    fract_x := math.lerp(sizeMin.x, sizeMax.x, fraction)
    // fg
    fg := im.GetForegroundDrawList()
    im.DrawList_AddRect(fg, sizeMin, {fract_x, sizeMax.y} , im.GetColorU32(im.Col.PlotHistogram))
    
    im.SetCursorPosY(cursorPos.y + lineHeight)
}
