package space_shooter

import "vendor:sdl2/mixer"

DEFAULT_CHUNK_SIZE     :: 4096
DEFAULT_MIXER_CHANNELS :: 16

SoundEffect :: enum {
    Laser_Player,
    Laser_Enemy,
    Powerup,
    Explosion,
    GameOver,
}

soundEffects := [SoundEffect]^mixer.Chunk {
    .Laser_Player = nil,
    .Laser_Enemy  = nil,
    .Powerup      = nil,
    .Explosion    = nil,
    .GameOver     = nil,
}

InitAudio :: proc() {
    mixer.OpenAudio(mixer.DEFAULT_FREQUENCY, mixer.DEFAULT_FORMAT, mixer.DEFAULT_CHANNELS, DEFAULT_CHUNK_SIZE)

    mixer.AllocateChannels(DEFAULT_MIXER_CHANNELS)

    soundEffects[SoundEffect.Laser_Player] = mixer.LoadWAV("assets/Laser1.wav")
    soundEffects[SoundEffect.Laser_Enemy]  = mixer.LoadWAV("assets/Laser2.wav")
    soundEffects[SoundEffect.Powerup]      = mixer.LoadWAV("assets/Powerup.wav")
    soundEffects[SoundEffect.Explosion]    = mixer.LoadWAV("assets/Explosion.wav")
    soundEffects[SoundEffect.GameOver]     = mixer.LoadWAV("assets/GameOver.wav")
}

DestroyAudio :: proc() {
    mixer.CloseAudio()

    for chunk, type in soundEffects {
        mixer.FreeChunk(chunk)
        soundEffects[type] = nil
    }
}

PlayEffect :: proc(type: SoundEffect) {
    effect := soundEffects[type]
    if effect == nil do return

    mixer.PlayChannel(-1, effect, 0)
}
