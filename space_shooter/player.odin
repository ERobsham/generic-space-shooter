package space_shooter

import "core:c"
import "core:fmt"
import "core:math"
import "vendor:sdl2"

import "../lib"
import "../lib/deltaT"
import "../lib/physics2d"


PLAYER_SPRITE :: SpriteInfo {
    ss_idx = 0,
    t_col = 0,
    t_row = 0,
    t_w = 64,
    t_h = 64,
}

PLAYER_MOVE_SPEED :: 500.0
PLAYER_ROF        :: 4.0 // ie shots per sec

PLAYER_MULITISHOT_MIN :: 0
PLAYER_MULITISHOT_MAX :: 9
PLAYER_SHOTSPEED_MIN  :: 1.0
PLAYER_SHOTSPEED_MAX  :: 3.0
PLAYER_ROF_MIN        :: 1.0
PLAYER_ROF_MAX        :: 5.0

PLAYER_DAMAGE_DEFAULT     :: 10.0
PLAYER_ENERGY_MAX_DEFAULT :: 100.0

PLAYER_ENERGY_REGEN_RATE_DEFAULT :: 100.0
PLAYER_ENERGY_REGEN_RATE_MAX     :: 1000.0

PLAYER_PROJ_COST :: 10.0

playerProjOrigins := [PLAYER_MULITISHOT_MAX]shotOrigin {
    { { f64(PLAYER_SPRITE.t_w) / 2 ,  0 }, .North }, // tip - top center
    { {  0, 40 }, .North }, // far left - wing tip
    { { f64(PLAYER_SPRITE.t_w), 40 }, .North }, // far right - wing tip
    { { 20, 10 }, .North }, // offset left - top
    { { f64(PLAYER_SPRITE.t_w)-20, 10 }, .North }, // offset right - top
    { {  0, 40 }, .NorthWest },
    { { f64(PLAYER_SPRITE.t_w), 40 }, .NorthEast },
    { { f64(PLAYER_SPRITE.t_w) / 2,  0 }, .NorthWest },
    { { f64(PLAYER_SPRITE.t_w) / 2,  0 }, .NorthEast },
}

Player :: struct {
    using gObj: lib.GameObject,

    processKeyboardInput: proc(self: ^Player, keyboard_state: [^]u8),

    sprite: AnimatedSprite,
    facing: Dir,
    
    shot_cooldown: f64,
    rof_mod      : f64,

    multi_shot      : u8,
    punch_through   : u8,
    shot_speed_mod  : f64,
    laser_efficiency: f64,

    damage: f64,

    energy    : f64,
    energy_max: f64,
    energy_regen_rate: f64,
}

shotOrigin :: struct {
    offset: physics2d.Vec2,
    dir: Dir,
}

InitPlayer :: proc() -> Player {
    p := Player{
        sprite = NewAnimiatedSprite(PLAYER_SPRITE, 3, 1.0/4.0),
        dimensions= { f64(PLAYER_SPRITE.t_w), f64(PLAYER_SPRITE.t_h) },

        processKeyboardInput = ProcessPlayerInput,

        update = proc(self: ^lib.GameObject, dt: f64) {
            UpdatePlayer(cast(^Player)self, dt)
        },
        draw = proc(self: ^lib.GameObject, renderer: ^sdl2.Renderer) {
            DrawPlayer(cast(^Player)self, renderer)
        },
    }
    ResetPlayer(&p)
    return p
}

ResetPlayer :: proc(p:^Player) {
    p.destroyed = false
    
    p.loc = { (W_WIDTH  / 2), (W_HEIGHT / 2) * 1.25 }
    p.dir = { 0, 0 }

    p.speed  = PLAYER_MOVE_SPEED
    p.facing = Dir.North

    p.shot_cooldown    = 0
    p.rof_mod          = 1.0
    p.multi_shot       = 0
    p.punch_through    = 0
    p.shot_speed_mod   = 1.0
    p.laser_efficiency = 1.0

    p.damage = PLAYER_DAMAGE_DEFAULT
    
    p.energy            = 0
    p.energy_max        = PLAYER_ENERGY_MAX_DEFAULT
    p.energy_regen_rate = PLAYER_ENERGY_REGEN_RATE_DEFAULT
}

ProcessPlayerInput :: proc(player: ^Player, keyboard_state: [^]u8) {
    using player
    
    if player.destroyed do return

    move_dir := GetMoveDir(keyboard_state)
    dir = VecFor(move_dir)

    shooting := GetShootingState(keyboard_state)
    if shooting && shot_cooldown <= 0 {
        shot_cooldown = 1.0 / (PLAYER_ROF * rof_mod)
        PlayEffect(.Laser_Player)
        generatePlayerProjectiles(player)
    }
}

UpdatePlayer :: proc(player: ^Player, dt: f64) {
    using player
    if destroyed do return

    sprite->update(dt)
    lib.MoveWithin(cast(^lib.GameObject)player, WindowBB, dt)

    if shot_cooldown > 0 do shot_cooldown -= dt

    if energy < energy_max {
        energy = clamp(energy+(energy_regen_rate*dt), 0.0, energy_max)
    }
}

DrawPlayer :: proc(player: ^Player, renderer: ^sdl2.Renderer) {
    using player
    if destroyed do return
    sprite->draw(renderer, lib.GetBoundingBox(cast(^lib.GameObject)player))
}

PlayerDestroyed :: proc(player: ^Player) {
    using player
    
    if destroyed do return
    destroyed = true

    bb := lib.GetBoundingBox(player)
    center := bb->getCenter()

    expl := CreateExplosionPtr(center)
    (cast(^SpaceShooterAPI)api)->addMisc(expl)

    PlayEffect(.GameOver)
}

ApplyPowerupToPlayer :: proc(player: ^Player, powerup: PowerupType) {
    if player.destroyed do return
    
    switch powerup {
        case .Multishot: {
            player.multi_shot = 
                clamp(player.multi_shot + 1, PLAYER_MULITISHOT_MIN, PLAYER_MULITISHOT_MAX-1)
        }
        case .ShotSpeed: {
            player.shot_speed_mod =
                clamp(player.shot_speed_mod + 0.2, PLAYER_SHOTSPEED_MIN, PLAYER_SHOTSPEED_MAX)
        }
        case .RateOfFire: {
            player.rof_mod =
                clamp(player.rof_mod + 0.2, PLAYER_ROF_MIN, PLAYER_ROF_MAX)
        }
    }

    PlayEffect(.Powerup)
}

@(private="file")
generatePlayerProjectiles :: proc(player: ^Player) {
    using player

    // if mulit_shot == 1, we want to shoot balanced from two sides
    offset := u8(multi_shot % 2)

    proj_cost := (PLAYER_PROJ_COST * ( 1.0 / laser_efficiency ))

    for i := u8(0 + offset); i <= (multi_shot + offset); i += 1 {
        if energy < proj_cost do return

        shot_origin := playerProjOrigins[i]
        
        shot_loc := physics2d.Vec2 {
            loc.x + shot_origin.offset.x,
            loc.y + shot_origin.offset.y,
        }
        
        // we want more like NNE/NNW, so make some custom adjustments for now.
        SQRT10 :: 3.162277660168379
        shot_dir := VecFor(shot_origin.dir)
        if shot_dir.x > 0 {
            shot_dir = { +1/SQRT10, -3/SQRT10 }
        } 
        else if shot_dir.x < 0 {
            shot_dir = { -1/SQRT10, -3/SQRT10 }
        }

        energy -= proj_cost

        proj := CreateProjectile(shot_loc, shot_dir)
        proj.speed = u32(f64(proj.speed) * shot_speed_mod)

        (cast(^SpaceShooterAPI)api)->addProjectile(proj)
    }
}
