package space_shooter

import "core:math/rand"

import "../lib/physics2d"

SPAWN_RATE  :: 1.0/1.0
MAX_ENEMIES :: 10

EnemySpawner :: struct {
    api: ^SpaceShooterAPI,
    
    spawn_rate: f64,
    cooldown  : f64,

    update: proc(self: ^EnemySpawner, dt: f64),
}

NewEnemySpawner :: proc(api: ^SpaceShooterAPI) -> EnemySpawner {
    return {
        api = api,

        spawn_rate = SPAWN_RATE,
        cooldown = SPAWN_RATE * 3,

        update = RunSpawner,
    }
}

RunSpawner :: proc(self: ^EnemySpawner, dt: f64) {
    using self

    if cooldown > 0 do cooldown -= dt

    if cooldown <= 0 {
        cooldown = spawn_rate

        bb := api->windowBB()

        x_rand := rand.float64_range(0, bb.dimensions.w - f64(ENEMY_SPRITE.t_w))

        inital_loc := physics2d.Vec2{
            x = x_rand,
            y = f64(-1 * ENEMY_SPRITE.t_h),
        }

        e := CreateEnemy(inital_loc, Dir.South)
        api->addEnemy(e)
    }
}
