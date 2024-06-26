// !!! Important to note that the y axis increases downwards (just like the screen coord. system)

const math = @import("math.zig");
const Vec2 = math.Vec2;
const Pos2 = math.Pos2;
const sq = math.sq;
const clamp = math.clamp;

pub const Size = struct { w: f32, h: f32 };

pub const Rect = struct {
    pos: Pos2,
    size: Size,

    pub fn getMidPoint(self: Rect) Pos2 {
        return .{
            .x = self.pos.x + (self.size.w / 2),
            .y = self.pos.y + (self.size.h / 2),
        };
    }
};

pub const Circle = struct {
    pos: Pos2,
    r: f32,

    vel: Vec2 = Vec2.ZERO,
    acc: Vec2 = Vec2.ZERO,

    pub fn mass(self: Circle) f32 {
        return self.r * 10;
    }

    /// Check if circle `c1` is overlapping with circle `c2`
    /// - If there is an overlap `return true`
    /// - If there is no overlap `return false`
    pub fn isOverlapingCircle(c1: Circle, c2: Circle) bool {
        const distanceSq = @abs(sq(c1.pos.x - c2.pos.x) + sq(c1.pos.y - c2.pos.y));
        const radiusSq = sq(c1.r + c2.r);

        return distanceSq < radiusSq;
    }

    /// Check if `circle` is overlapping `rect`
    /// - If there is an overlap `return true`
    /// - If there is no overlap `return false`
    pub fn isOverlapingRect(circle: Circle, rect: Rect) bool {
        // We can get the point closest to the circle with clamping:
        const collisionPoint = Pos2{
            .x = clamp(circle.pos.x, rect.pos.x, rect.pos.x + rect.size.w),
            .y = clamp(circle.pos.x, rect.pos.y, rect.pos.y + rect.size.h),
        };

        const distanceFromRect = Pos2.getDistance(circle.pos, collisionPoint);

        return distanceFromRect < circle.r;
    }
};

// ==========================================================================
const testing = @import("std").testing;
const FLOAT_TOLERANCE = 0.001;

test "circle_overlap_circle" {
    // Test randomly picked values:
    const circle = Circle{ .pos = .{ .x = 1, .y = 1 }, .r = 10 };

    const c1 = Circle{ .pos = .{ .x = 13.01, .y = 1 }, .r = 2 };
    const c2 = Circle{ .pos = .{ .x = 12.99, .y = 1 }, .r = 2 };

    try testing.expect(circle.isOverlapingCircle(c1) == false);
    try testing.expect(circle.isOverlapingCircle(c2) == true);

    const c3 = Circle{ .pos = circle.pos, .r = 1 };
    const c4 = Circle{ .pos = circle.pos, .r = 15 };

    try testing.expect(circle.isOverlapingCircle(c3) == true);
    try testing.expect(circle.isOverlapingCircle(c4) == true);
    try testing.expect(circle.isOverlapingCircle(circle) == true);

    const c5 = Circle{ .pos = .{ .x = 1000000, .y = 30000 }, .r = 1500000 };
    const c6 = Circle{ .pos = .{ .x = 1000000, .y = 1500 }, .r = 150 };

    try testing.expect(circle.isOverlapingCircle(c5) == true);
    try testing.expect(circle.isOverlapingCircle(c6) == false);
}

test "circle_overlap_rect" {
    // Test randomly picked values:
    const circle = Circle{ .pos = .{ .x = 1, .y = 1 }, .r = 1 };

    const r1 = Rect{
        .pos = .{ .x = 2.01, .y = 0 },
        .size = .{ .w = 1, .h = 2 },
    };
    const r2 = Rect{
        .pos = .{ .x = 1.99, .y = 0 },
        .size = .{ .w = 1, .h = 2 },
    };

    try testing.expect(circle.isOverlapingRect(r1) == false);
    try testing.expect(circle.isOverlapingRect(r2) == true);

    const r3 = Rect{
        .pos = .{
            .x = circle.pos.x - 0.05,
            .y = circle.pos.y - 0.05,
        },
        .size = .{ .w = 0.1, .h = 0.1 },
    };
    const r4 = Rect{
        .pos = .{ .x = -4, .y = -4 },
        .size = .{ .w = 10, .h = 10 },
    };

    try testing.expect(circle.isOverlapingRect(r3) == true);
    try testing.expect(circle.isOverlapingRect(r4) == true);
}

test "rect_mid_point" {
    const r1 = Rect{
        .pos = .{ .x = 0, .y = 0 },
        .size = .{ .w = 0, .h = 0 },
    };
    const r2 = Rect{
        .pos = .{ .x = -1, .y = -1 },
        .size = .{ .w = 2, .h = 2 },
    };

    try testing.expectApproxEqRel(r1.pos.x, r1.getMidPoint().x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(r1.pos.y, r1.getMidPoint().y, FLOAT_TOLERANCE);

    try testing.expectApproxEqRel(0, r2.getMidPoint().x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(0, r2.getMidPoint().y, FLOAT_TOLERANCE);
}
