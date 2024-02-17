package space_shooter

import "vendor:sdl2"
import "vendor:sdl2/image"

import "../lib/physics2d"

// 512x512 sprite sheet w/ 64x64 chunks (ie 8x8 sprites total)
SPRITESHEET_DIM     :: 64
SPRITESHEET_MAX_IDX :: 8

SpriteSheetIdx :: u8

SpriteInfo :: struct {
    ss_idx  : SpriteSheetIdx,
    t_col, t_row: i32, // col == x / row == y
    t_w, t_h: i32,
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

DrawSprite :: proc(renderer: ^sdl2.Renderer, from: SpriteInfo, to: physics2d.BoundingBox) {
    assert(sprite_sheets != nil, "sprite sheets not initialized")
    assert(int(from.ss_idx) < len(sprite_sheets), "invalid sprite sheet index")

    src  := sdl2.Rect{
        from.t_col * SPRITESHEET_DIM, 
        from.t_row * SPRITESHEET_DIM, 
        from.t_w, 
        from.t_h,
    }
    dest := sdl2.Rect{
        i32(to.origin.x),     i32(to.origin.y), 
        i32(to.dimensions.w), i32(to.dimensions.h),
    }

    sdl2.RenderCopy(renderer, sprite_sheets[from.ss_idx], &src, &dest)
}