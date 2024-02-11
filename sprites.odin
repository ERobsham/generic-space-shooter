package main

import "vendor:sdl2"
import "vendor:sdl2/image"


// 512x512 sprite sheet w/ 64x64 chunks (ie 8x8 sprites total)
SPRITESHEET_DIM :: 64

spriteSheet: ^sdl2.Texture = nil


SpriteCoords :: struct {
    tx, ty : i32,
    w, h   : i32,
}


InitSpriteSheet :: proc(renderer: ^sdl2.Renderer) {
    tex := image.LoadTexture(renderer, "assets/player.png")
    assert(tex != nil, "unable to load player texture")

    spriteSheet = tex
}

DestroySpriteSheet :: proc() {
    if spriteSheet != nil {
        sdl2.DestroyTexture(spriteSheet)
        spriteSheet = nil
    }
}

DrawSprite :: proc(renderer: ^sdl2.Renderer, from: SpriteCoords, to: BoundingBox) {
    assert(spriteSheet != nil, "sprite sheet not initialized")

    src  := sdl2.Rect{from.tx, from.ty, from.w, from.h}
    dest := sdl2.Rect{to.x, to.y, to.w, to.h}

    sdl2.RenderCopy(renderer, spriteSheet, &src, &dest)
}