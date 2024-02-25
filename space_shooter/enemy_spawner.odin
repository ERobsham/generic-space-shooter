package space_shooter

import "core:math/rand"

import "../lib/physics2d"

SPAWN_RATE  :: 1.0/4.0

ENEMIES_PER_WAVE :: 15
WAVE_COOLDOWN   :: 5.0

EnemySpawner :: struct {
    api: ^SpaceShooterAPI,
    
    spawn_rate: f64,
    cooldown  : f64,

    wave_spawns_remaining: u64,
    wave                 : u64,

    update: proc(self: ^EnemySpawner, dt: f64),
}

NewEnemySpawner :: proc(api: ^SpaceShooterAPI) -> EnemySpawner {
    s := EnemySpawner {
        api = api,
        update = RunSpawner,
    }
    ResetSpawner(&s)
    return s
}

ResetSpawner :: proc(s: ^EnemySpawner) {
    s.spawn_rate = SPAWN_RATE
    s.cooldown   = 3.0  // initial cooldown before enemeis spawn

    s.wave_spawns_remaining = ENEMIES_PER_WAVE
    s.wave                  = 1
}

RunSpawner :: proc(self: ^EnemySpawner, dt: f64) {
    using self

    if cooldown > 0 do cooldown -= dt

    if cooldown <= 0 {
        cooldown = spawn_rate

        if wave_spawns_remaining == 0 {
            cooldown = WAVE_COOLDOWN
            wave_spawns_remaining = ENEMIES_PER_WAVE
            wave += 1
            return
        }

        path := &enemeyPath1
        if wave % 2 == 0 {
            path = &enemeyPath1_mirrored
        }
        if wave % 3 == 0 {
            if wave_spawns_remaining % 2 == 0 {
                path = &enemeyPath1
            } else {
                path = &enemeyPath1_mirrored
            }
        }

        e := CreateEnemy({-20, -20}, path)
        api->addEnemy(e)
        wave_spawns_remaining -= 1
    }
}
