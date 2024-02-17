package space_shooter

import "../lib/physics2d"

enemeyPathSplinePoints1 := []physics2d.Vec2{
    {350, -50},
    {120, -50},
    {120, 0},
    {80, 220},
    {180, 380},
    {480, 480},
    {660, 340},
    {580, 200},
    {420, 320},
    {320, 220},
    {460, 120},
    {600, 0},
    {600, -50},
    {120, -50},
}
enemeyPath1 := physics2d.NewSpline(enemeyPathSplinePoints1)
enemeyPath1_mirrored := physics2d.SplineFlippedHorizontally(&enemeyPath1, f64(W_WIDTH))
