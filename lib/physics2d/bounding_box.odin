package physics2d

BoundingBox :: struct {
    origin : Vec2,
    dimensions : Dim2,

    getCenter  : proc(this: ^BoundingBox) -> Vec2,
    isWithin   : proc(this: ^BoundingBox, other: BoundingBox) -> bool,
    isColliding: proc(this: ^BoundingBox, other: BoundingBox) -> bool,
}

NewBoundingBox :: proc (x,y,w,h: f64) -> BoundingBox {
    origin     := Vec2{ x,y }
    dimensions := Dim2{ w,h }
    return BoundingBox{
        origin,
        dimensions,

        GetCenter,
        IsWithin,
        IsColliding,
    }
}

// answers the question: does `other` fully contain `this`?
IsWithin :: proc(this: ^BoundingBox, other: BoundingBox) -> bool {
    return this.origin.x >= other.origin.x && 
        this.origin.y >= other.origin.y &&    
        this.origin.x + this.dimensions.w <= other.origin.x + other.dimensions.w && 
        this.origin.y + this.dimensions.h <= other.origin.y + other.dimensions.h
}

// answers the question: does `this` in any way overlap with `other`?
IsColliding :: proc(this: ^BoundingBox, other: BoundingBox) -> bool {
    return ( (this.origin.x >= other.origin.x && this.origin.x          <= other.origin.x + other.dimensions.w) || 
             (this.origin.x <  other.origin.x && this.origin.x + this.dimensions.w >= other.origin.x          )    ) && 
           ( (this.origin.y >= other.origin.y && this.origin.y          <= other.origin.y + other.dimensions.h) ||
             (this.origin.y <  other.origin.y && this.origin.y + this.dimensions.h >= other.origin.y          )    )
}

GetCenter :: proc(this: ^BoundingBox) -> Vec2 {
    using this
    return Vec2{ 
        origin.x + (dimensions.w / 2),
        origin.y + (dimensions.h / 2),
    }
}