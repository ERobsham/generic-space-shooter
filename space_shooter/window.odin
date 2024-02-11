package space_shooter

import "vendor:sdl2"

import "../lib/collision"

W_TITLE    :: "Space Shoot 'em up"
W_ORIGIN_X :: sdl2.WINDOWPOS_CENTERED
W_ORIGIN_Y :: sdl2.WINDOWPOS_CENTERED
W_WIDTH    :: 1024
W_HEIGHT   :: 768
W_FLAGS    :: (sdl2.WINDOW_INPUT_FOCUS|sdl2.WINDOW_MOUSE_FOCUS)

WindowBB := collision.BoundingBox {
    0,0,
    W_WIDTH, W_HEIGHT,
}