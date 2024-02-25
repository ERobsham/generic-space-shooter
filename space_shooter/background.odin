package space_shooter

import "core:math/rand"
import "vendor:sdl2"

import "../lib/physics2d"

BG_TILE_SIZE :: 64

BG_NUM_COLS :: W_WIDTH / BG_TILE_SIZE
BG_NUM_ROWS :: (W_HEIGHT / BG_TILE_SIZE) + 1

BG_SPRITE :: SpriteInfo {
    ss_idx = 0,
    t_row = 0,
    t_col = 4,
    t_w = BG_TILE_SIZE,
    t_h = BG_TILE_SIZE,
}

BG_SCROLL_SPEED :: 100

Background :: struct {
    tile_map: [BG_NUM_ROWS]TileRow,
}

TileRow :: struct {
    tiles: [BG_NUM_COLS]Tile,
    y_offset: f64,
}

Tile :: struct {
    bg_col_offset:i32,
    fg_col_offset:i32,
    overlay_col_offset:i32,

    use_overlay:bool,
}

NewBackground :: proc() -> Background {
    bg := Background {}

    for i := 0; i < len(bg.tile_map); i += 1 {
        bg.tile_map[i] = newTileRow(i)
    }

    return bg
}

UpdateBackground :: proc(self:^Background, dt: f64) {
    using self
    for &row in tile_map {
        updateRow(&row, dt)
    }
}

DrawBackground :: proc(self:^Background, renderer: ^sdl2.Renderer) {
    using self

    bb := physics2d.NewBoundingBox(0,0, W_WIDTH, W_HEIGHT)

    // draw tile bg
    DrawSprite(renderer,
        SpriteInfo {
            ss_idx = BG_SPRITE.ss_idx,
            t_row = BG_SPRITE.t_row,
            t_col = BG_SPRITE.t_col,
            t_w = BG_SPRITE.t_w * 3,
            t_h = BG_SPRITE.t_h,
        }, 
        bb)

    for &row in tile_map {
        drawRow(&row, renderer)
    }
}

// ----------------------------------
// TileRow Functions
// ----------------------------------

@(private="file")
newTileRow :: proc(row_idx: int) -> TileRow {
    row := TileRow {}
    row.y_offset = f64((BG_TILE_SIZE * -1) + (row_idx * BG_TILE_SIZE) )
    for i := 0; i < len(row.tiles); i += 1 {
        row.tiles[i] = newTile(i)
    }
    return row
}

@(private="file")
resetTileRow:: proc(self:^TileRow) {
    using self

    for i := 0; i < len(tiles); i += 1 {
        randomizeTile(&tiles[i])
        y_offset = f64(BG_TILE_SIZE * -1)
    }
}

@(private="file")
updateRow :: proc(self:^TileRow, dt:f64) {
    using self

    y_offset += f64(BG_SCROLL_SPEED) * dt

    if y_offset > f64(W_HEIGHT) {
        resetTileRow(self)
    }
}

@(private="file")
drawRow :: proc(self:^TileRow, renderer: ^sdl2.Renderer) {
    using self
    
    bb := physics2d.NewBoundingBox(0, y_offset, BG_TILE_SIZE, BG_TILE_SIZE)

    for &tile in tiles {
        drawTileAt(&tile, renderer, bb)
        bb.origin.x += BG_TILE_SIZE
    }
}



// ----------------------------------
// Tile Functions
// ----------------------------------

@(private="file")
newTile :: proc(idx:int) -> Tile {
    t := Tile {}
    if idx > 0 {
        t.bg_col_offset += 1
    }
    if idx == BG_NUM_COLS-1 {
        t.bg_col_offset += 1
    }
    randomizeTile(&t)
    return t
}

@(private="file")
randomizeTile :: proc(self:^Tile) {
    using self

    // randomly pick if we should draw an extra overlay detail
    rand_overlay: [8]bool = { true,false,false,false,false,false,false,false }
    use_overlay = rand.choice(rand_overlay[:])    
    
    // randomly pick which tiles to use
    rand_offset:  [4]i32  = { 0,1,2,3 }
    fg_col_offset      = rand.choice(rand_offset[:])
    overlay_col_offset = rand.choice(rand_offset[:])
}

@(private="file")
drawTileAt :: proc(self:^Tile, renderer: ^sdl2.Renderer, bb: physics2d.BoundingBox) {
    using self

    // draw tile fg
    DrawSprite(renderer,
        SpriteInfo {
            ss_idx = BG_SPRITE.ss_idx,
            t_row = BG_SPRITE.t_row + 1,
            t_col = BG_SPRITE.t_col + fg_col_offset,
            t_w = BG_SPRITE.t_w,
            t_h = BG_SPRITE.t_h,
        }, 
        bb)
        
    if !use_overlay do return
    
    // draw tile overlay
    DrawSprite(renderer,
        SpriteInfo {
            ss_idx = BG_SPRITE.ss_idx,
            t_row = BG_SPRITE.t_row + 2,
            t_col = BG_SPRITE.t_col + overlay_col_offset,
            t_w = BG_SPRITE.t_w,
            t_h = BG_SPRITE.t_h,
        }, 
        bb)
}
