// !!! Important to note that the y axis increases downwards (just like the screen coord. system)

pub const Vec2 = struct {
    x: f32 = 0,
    y: f32 = 0,

    pub const ZERO = Vec2{ .x = 0, .y = 0 };

    /// Get the length of `self`
    pub fn getLength(self: Vec2) f32 {
        return sqrt(sq(self.x) + sq(self.y));
    }

    /// Get the normal vector of `self`
    pub fn getNormal(self: Vec2) ?Vec2 {
        if (self.x == 0 and self.y == 0) return null;

        const length = self.getLength();
        return .{
            .x = self.x / length,
            .y = self.y / length,
        };
    }

    pub fn normalize(self: *Vec2) void {
        if (self.getNormal()) |normal| {
            self.* = normal;
        }
    }

    pub fn getScaled(self: Vec2, scaler: f32) ?Vec2 {
        var normal = self.getNormal() orelse return null;
        normal.x *= scaler;
        normal.y *= scaler;

        return normal;
    }

    pub fn scale(self: *Vec2, scaler: f32) void {
        self.normalize();
        self.x *= scaler;
        self.y *= scaler;
    }
};

pub const Pos2 = struct {
    x: f32 = 0,
    y: f32 = 0,

    pub const ZERO = Vec2{ .x = 0, .y = 0 };

    pub fn getVectorTo(start: Pos2, end: Pos2) Vec2 {
        return .{
            .x = end.x - start.x,
            .y = end.y - start.y,
        };
    }

    /// Return the distance between `p1` and `p2`
    pub fn getDistance(p1: Pos2, p2: Pos2) f32 {
        return Vec2.getLength(
            p1.getVectorTo(p2),
        );
    }
};

/// Force num between min and max.
/// - If min < num < max -> return num
/// - If max < num -> return max
/// - If min > num -> return min
pub fn clamp(num: f32, min: f32, max: f32) f32 {
    if (min > max) unreachable;

    return @max(min, @min(max, num));
}

/// Square of `num`
pub fn sq(num: f32) f32 {
    return num * num;
}

/// Fast square root approximation by John Carmack
/// https://en.wikipedia.org/wiki/Fast_inverse_square_root
pub fn sqrt(num: f32) f32 {
    if (num < 0) unreachable;

    var i: i32 = undefined;
    var x: f32 = undefined;
    var y: f32 = undefined;

    x = num * 0.5;
    y = num;
    i = @as(*i32, @ptrCast(&y)).*;
    i = 0x5f3759df - (i >> 1);
    y = @as(*f32, @ptrCast(&i)).*;
    y = y * (1.5 - (x * y * y));
    y = y * (1.5 - (x * y * y));

    return num * y;
}

/// sqrt with the negative and 0 defined
pub fn nsqrt(num: f32) f32 {
    return if (num > 0) sqrt(num) else if (num < 0) -1 * sqrt(-num) else 0;
}

/// Fast random number generator by Lehmer
/// https://en.wikipedia.org/wiki/Lehmer_random_number_generator
pub fn rand() u64 {
    if (!initialized) unreachable;

    s = s +% 0xe120fc15;

    // Short for magic
    var M: u64 = s *% 0x4a39b70d;
    const m1: u64 = (M >> 32) ^ M;
    M = m1 *% 0x12fad5c9;
    const m2: u64 = (M >> 32) ^ M;

    return m2;
}

/// Short for seed
/// Is used to generate random numbers
var s: u64 = undefined;
var initialized = false;

/// Is used to initialize the Lehmer random number generator
/// Not calling this before using `rand` is undefined behavior
pub fn seed(newSeed: u64) void {
    s = newSeed;
    initialized = true;
}

// ==========================================================================
const testing = @import("std").testing;
const FLOAT_TOLERANCE = 0.001;

test "clamp" {
    const min = -2;
    const max = 15;

    for (0..40) |i| {
        const num = @as(f32, @floatFromInt(i)) - 20;

        const result = if (min > num) min else if (max < num) max else num;

        try testing.expectApproxEqRel(result, clamp(num, min, max), FLOAT_TOLERANCE);
    }
}

test "sq" {
    // Test on range:
    for (0..300) |i| {
        const num = @as(f32, @floatFromInt(i)) - 150;
        try testing.expectApproxEqRel(num * num, sq(num), FLOAT_TOLERANCE);
    }

    // Test randomly picked values:
    try testing.expectApproxEqRel(0, sq(0), FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(25, sq(5), FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(25, sq(-5), FLOAT_TOLERANCE);
}

test "sqrt" {
    for (0..300) |i| {
        const num: f32 = @floatFromInt(i);
        try testing.expectApproxEqRel(@sqrt(num), sqrt(num), FLOAT_TOLERANCE);
    }

    // Test randomly picked values:
    try testing.expectApproxEqRel(0, sqrt(0), FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(1, sqrt(1), FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(1.41421, sqrt(2), FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(3.1622, sqrt(10), FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(5, sqrt(25), FLOAT_TOLERANCE);
}

test "vec2_length" {
    for (0..50) |i| {
        for (0..50) |j| {
            const x = @as(f32, @floatFromInt(j)) - 25;
            const y = @as(f32, @floatFromInt(i)) - 25;

            const vec = Vec2{ .x = x, .y = y };

            try testing.expectApproxEqRel(@sqrt(x * x + y * y), vec.getLength(), FLOAT_TOLERANCE);
        }
    }

    // Test randomly picked vectors:
    const v1 = Vec2{ .x = 3, .y = 4 };
    try testing.expectApproxEqRel(5, v1.getLength(), FLOAT_TOLERANCE);

    const v2 = Vec2{ .x = 8, .y = -6 };
    try testing.expectApproxEqRel(10, v2.getLength(), FLOAT_TOLERANCE);
}

test "pos_distance" {
    for (0..30) |i| {
        for (0..30) |j| {
            for (0..30) |k| {
                for (0..30) |l| {
                    const x1 = @as(f32, @floatFromInt(j)) - 25;
                    const y1 = @as(f32, @floatFromInt(i)) - 25;
                    const x2 = @as(f32, @floatFromInt(l)) - 25;
                    const y2 = @as(f32, @floatFromInt(k)) - 25;

                    const p1 = Pos2{ .x = x1, .y = y1 };
                    const p2 = Pos2{ .x = x2, .y = y2 };

                    const dX = @abs(p1.x - p2.x);
                    const dY = @abs(p1.y - p2.y);

                    try testing.expectApproxEqRel(@sqrt(sq(dX) + sq(dY)), Pos2.getDistance(p1, p2), FLOAT_TOLERANCE);
                }
            }
        }
    }

    // Test randomly picked vectors:
    const p1 = Pos2{ .x = 0.0, .y = 0.0 };
    const p2 = Pos2{ .x = 52.75, .y = 988.01 };

    try testing.expectApproxEqRel(Vec2.getLength(.{ .x = p2.x, .y = p2.y }), Pos2.getDistance(p1, p2), FLOAT_TOLERANCE);

    const p3 = Pos2{ .x = 7, .y = -5 };
    const p4 = Pos2{ .x = -1, .y = -11 };

    try testing.expectApproxEqRel(10, p3.getDistance(p4), FLOAT_TOLERANCE);
}

test "vector_to" {
    const p1 = Pos2{ .x = -98.0076, .y = 731.7009 };
    const v1 = p1.getVectorTo(p1);

    try testing.expectApproxEqRel(0.0, v1.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(0.0, v1.y, FLOAT_TOLERANCE);

    const v2 = Pos2.getVectorTo(
        .{ .x = 0, .y = 0 },
        .{ .x = 123.5, .y = -346.075 },
    );

    try testing.expectApproxEqRel(123.5, v2.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(-346.075, v2.y, FLOAT_TOLERANCE);

    const v3 = Pos2.getVectorTo(
        .{ .x = -10, .y = 0 },
        .{ .x = 10, .y = 0 },
    );
    const v4 = Pos2.getVectorTo(
        .{ .x = 10, .y = 0 },
        .{ .x = -10, .y = 0 },
    );
    const v5 = Pos2.getVectorTo(
        .{ .x = -1, .y = -11 },
        .{ .x = 7, .y = -5 },
    );

    try testing.expectApproxEqRel(20, v3.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(0, v3.y, FLOAT_TOLERANCE);

    try testing.expectApproxEqRel(-20, v4.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(0, v4.y, FLOAT_TOLERANCE);

    try testing.expectApproxEqRel(8, v5.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(6, v5.y, FLOAT_TOLERANCE);
}

test "vec2_normal" {
    // Test randomly picked vectors:
    const v1 = Vec2{ .x = 3, .y = 4 };
    const n1 = v1.getNormal().?;
    try testing.expectApproxEqRel(0.6, n1.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(0.8, n1.y, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(1, n1.getLength(), FLOAT_TOLERANCE);

    const v2 = Vec2{ .x = 3000, .y = -4000 };
    const n2 = v2.getNormal().?;
    try testing.expectApproxEqRel(n1.x, n2.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(-n1.y, n2.y, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(1, n2.getLength(), FLOAT_TOLERANCE);

    const v3 = Vec2{ .x = 1, .y = 0 };
    const n3 = v3.getNormal().?;
    try testing.expectApproxEqRel(1, v3.getLength(), FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(v3.x, n3.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(v3.y, n3.y, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(1, n3.getLength(), FLOAT_TOLERANCE);

    const v4 = Vec2.ZERO;
    const n4 = v4.getNormal();

    try testing.expectEqual(null, n4);
}

test "vec2_scale" {
    const v1_original = Vec2{ .x = 3, .y = 4 };
    const n1_original = v1_original.getNormal().?;
    var v1 = v1_original;
    v1.scale(5);
    var n1 = v1.getNormal().?;

    try testing.expectApproxEqRel(5, v1.getLength(), FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(n1_original.x, n1.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(n1_original.y, n1.y, FLOAT_TOLERANCE);

    v1.scale(-2);
    n1 = v1.getNormal().?;

    try testing.expectApproxEqRel(2, v1.getLength(), FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(-1.0 * n1_original.x, n1.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(-1.0 * n1_original.y, n1.y, FLOAT_TOLERANCE);
}
