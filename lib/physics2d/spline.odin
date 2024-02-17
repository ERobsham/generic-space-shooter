package physics2d

import "core:fmt"

// Catmull-Rom Spline
NewSpline :: proc (control_points: []Vec2) -> Spline {
    assert(len(control_points) >= 4, "NewSpline(): splines require at least 4 control points to be valid")

    s := Spline{
        ctl_points = make([dynamic]point, 0, len(control_points)),
        length = splineLength,
        pointAt = getPointAt,
    }

    for v in control_points {
        using s
        append(&ctl_points, point{ v.x, v.y })
    }

    return s
}

Spline :: struct {
    ctl_points: [dynamic]point,

    length: proc(s:^Spline) -> int,
    pointAt: proc(spline: ^Spline, t: f64) -> Vec2,
}

@(private="file")
point :: [2]f64

@(private="file")
splineLength :: proc(s: ^Spline) -> int {
    return len(s.ctl_points) - 3
}

@(private="file")
getPointAt :: proc(spline: ^Spline, t: f64) -> Vec2 {
    assert(int(t) >= 0, "GetPointAt: t must be greater than 1")
    assert(t <= f64(len(spline.ctl_points)-3), "GetPointAt: t must not exceed num control points - 3")
    #no_bounds_check {
        // setup our 'window' of 4 points
        // `p0` is just a control point, so our 
        // `t == 0` case should == `ctl_points[1]`
        curve_idx := int(t)
        pts := [4]point{
            spline.ctl_points[curve_idx],
            spline.ctl_points[curve_idx+1],
            spline.ctl_points[curve_idx+2],
            spline.ctl_points[curve_idx+3],
        }

        // we only want the fractional leftover,
        t := t - f64( int(t) )
        t_sq := t*t
        t_cu := t_sq*t
        weights := [4]f64 {
            (-1.0*t_cu) + (2.0*t_sq) - t,
            ( 3.0*t_cu) - (5.0*t_sq) + 2.0,
            (-3.0*t_cu) + (4.0*t_sq) + t,
            ( 1.0*t_cu) - (1.0*t_sq),
        }

        pts[0] *= weights[0] * 0.5
        pts[1] *= weights[1] * 0.5
        pts[2] *= weights[2] * 0.5
        pts[3] *= weights[3] * 0.5
        
        pt := pts[0]+pts[1]+pts[2]+pts[3]
        return Vec2{ pt.x, pt.y }
    }
}