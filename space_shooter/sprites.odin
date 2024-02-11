package space_shooter

import "vendor:sdl2"
import "vendor:sdl2/image"

import "../lib/collision"

// 512x512 sprite sheet w/ 64x64 chunks (ie 8x8 sprites total)
SPRITESHEET_DIM     :: 64
SPRITESHEET_MAX_IDX :: 8

SpriteSheetIdx :: u8

SpriteCoords :: struct {
    tx, ty : i32,
    w, h   : i32,
}

sprite_sheets: [dynamic]^sdl2.Texture = nil

InitSpriteSheets :: proc(renderer: ^sdl2.Renderer, ss_paths: []cstring) {
    
    sprite_sheets = make([dynamic]^sdl2.Texture, 0, len(ss_paths))

    for path in ss_paths {
        tex := image.LoadTexture(renderer, path)
        assert(tex != nil, "unable to load texture")

        append(&sprite_sheets, tex)
    }
}

DestroySpriteSheets :: proc() {
    if sprite_sheets != nil {
        for sheet in sprite_sheets {
            sdl2.DestroyTexture(sheet)
        }

        delete(sprite_sheets)
        sprite_sheets = nil
    }
}

DrawSprite :: proc(renderer: ^sdl2.Renderer, 
                   sheetIdx: SpriteSheetIdx, 
                       from: SpriteCoords,
                         to: collision.BoundingBox) {
    assert(sprite_sheets != nil, "sprite sheets not initialized")
    assert(int(sheetIdx) < len(sprite_sheets), "invalid sprite sheet index")

    src  := sdl2.Rect{from.tx, from.ty, from.w, from.h}
    dest := sdl2.Rect{to.x, to.y, to.w, to.h}

    sdl2.RenderCopy(renderer, sprite_sheets[sheetIdx], &src, &dest)
}