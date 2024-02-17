package space_shooter

import "../lib"
import "../lib/physics2d"

SpaceShooterAPI :: struct {
    using gsAPI   : lib.GameStateAPI,
    addEnemy      : proc(self: ^SpaceShooterAPI, enemy: Enemy),
    addProjectile : proc(self: ^SpaceShooterAPI, proj: Projectile),
    addPowerup    : proc(self: ^SpaceShooterAPI, powerup: Powerup),
    addMisc       : proc(self: ^SpaceShooterAPI, misc: ^lib.GameObject),
    windowBB      : proc(self: ^SpaceShooterAPI) -> physics2d.BoundingBox,
}

//
// space shooter 'API' methods
//

AddEnemy :: proc(api: ^GameState, enemy: Enemy) {
    e := enemy
    e.api = api
    append(&api.enemies, e)
}

AddProjectile :: proc(api: ^GameState, proj: Projectile) {
    p := proj
    p.api = api
    append(&api.projectiles, p)
}

AddPowerup :: proc(api: ^GameState, powerup: Powerup) {
    p := powerup
    p.api = api
    append(&api.powerups, p)
}

AddMisc :: proc(api: ^GameState, misc: ^lib.GameObject) {
    misc.api = api
    append(&api.misc_objs, misc)
}