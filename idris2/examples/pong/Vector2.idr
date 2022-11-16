public export
record Vector2 t where
    constructor MkVector2
    x: t
    y: t

Eq t => Eq (Vector2 t) where
    MkVector2 ax ay == MkVector2 bx by = (ax == bx) && (ay == by)
    a /= b = not (a == b)