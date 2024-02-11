package space_shooter

import "vendor:sdl2"

import "../lib"
import "../lib/move"

PROJECTILE_SPRITESHEET_IDX_X :: 0
PROJECTILE_SPRITESHEET_IDX_Y :: 4
PROJECTILE_SPRITE_W :: 3
PROJECTILE_SPRITE_H :: 12

PROJECTILE_SPEED :: 1200


Projectile :: struct {
    using lib.GameObject,
}

CreateProjectile :: proc(s:^GameState, at: move.Vec2, dir: move.Vec2) {
    p := Projectile{
        loc = at,
        dimensions = { PROJECTILE_SPRITE_W, PROJECTILE_SPRITE_H },
        
        dir = dir,
        speed = PROJECTILE_SPEED,

        update = proc(self: ^lib.GameObject, dt: f64) {
            UpdateProjectile(cast(^Projectile)self, dt)
        },
        draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
            DrawProjectile(cast(^Projectile)self, renderer)
        },
    }

}


UpdateProjectile :: proc(proj:^Projectile, dt: f64) {

}

DrawProjectile :: proc(proj:^Projectile, renderer: ^sdl2.Renderer) {
    if proj.destryed do return


}
