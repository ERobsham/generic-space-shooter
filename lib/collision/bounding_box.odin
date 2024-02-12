package collison

import "../move"

BoundingBox :: struct {
    // origin
    x,y : i32,
    
    // size
    w,h : i32,

    getCenter  : proc(this: ^BoundingBox) -> move.Vec2,
    isWithin   : proc(this: ^BoundingBox, other: BoundingBox) -> bool,
    isColliding: proc(this: ^BoundingBox, other: BoundingBox) -> bool,
}

NewBoundingBox :: proc (x,y,w,h: i32) -> BoundingBox {
    return BoundingBox{
       x, y,
       w, h,

        GetCenter,
        IsWithin,
        IsColliding,
    }
}

// answers the question: does `other` fully contain `this`?
IsWithin :: proc(this: ^BoundingBox, other: BoundingBox) -> bool {
    return this.x >= other.x && 
        this.y >= other.y &&    
        this.x + this.w <= other.x + other.w && 
        this.y + this.h <= other.y + other.h
}

// answers the question: does `this` in any way overlap with `other`?
IsColliding :: proc(this: ^BoundingBox, other: BoundingBox) -> bool {
    return ( (this.x >= other.x && this.x          <= other.x + other.w) || 
             (this.x <  other.x && this.x + this.w >= other.x          )    ) && 
           ( (this.y >= other.y && this.y          <= other.y + other.h) ||
             (this.y <  other.y && this.y + this.h >= other.y          )    )
}

GetCenter :: proc(this: ^BoundingBox) -> move.Vec2 {
    using this
    return move.Vec2{ 
        f64( (x+w) / 2 ),
        f64( (y+h) / 2 ),
    }
}