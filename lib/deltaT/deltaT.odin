package deltaT

import "vendor:sdl2"


DT_GRANULARITY :u64: 1000 // ms

@(private)
last_timestamp : u64 = 0
@(private)
last_dt_frac_sec : f64 = 0.0

@(private)
currentTimestamp :: proc() -> u64 {
    return sdl2.GetPerformanceCounter() / (sdl2.GetPerformanceFrequency() / DT_GRANULARITY)
}

Init :: proc() {
    last_timestamp = currentTimestamp()
}

Get :: proc() -> f64 {
    timestamp := currentTimestamp()
    dt_ms := timestamp - last_timestamp
    if dt_ms == 0 do return last_dt_frac_sec

    dt_frac_sec := (f64(dt_ms) / 1000.0)
    
    last_dt_frac_sec = dt_frac_sec
    last_timestamp = timestamp
    
    return dt_frac_sec
}

CurrentMS :: proc () -> u64 {
    return currentTimestamp()
}

CurrentSec :: proc () -> u64 {
    return currentTimestamp() / 1000
}