const rl = @import("raylib");
const math = @import("math.zig");
const shapes = @import("shapes.zig");
const Vec2 = math.Vec2;
const Pos2 = math.Pos2;
const Rect = shapes.Rect;
const Size = shapes.Size;

pub fn getScreenSize() Size {
    return .{
        .w = @floatFromInt(rl.getScreenWidth()),
        .h = @floatFromInt(rl.getScreenHeight()),
    };
}

const Camera = struct {
    rect: Rect,

    /// Instantly move the camera to set the midle of the camera on `pos`
    pub fn focusOn(self: *Camera, pos: Pos2) void {
        const midleOfCamera = self.rect.getMidPoint();

        const delta = midleOfCamera.getVectorTo(pos);

        self.*.rect.pos.x += delta.x;
        self.*.rect.pos.y += delta.y;
    }

    const ScreenRect = struct {
        pos: struct { x: i32, y: i32 },
        size: struct { w: i32, h: i32 },
    };
    /// Function shall calculate where to draw the given `gameRect` based on the position of `self: Camera` and the `screenSize`
    /// - Function does not check if the returned `ScreenRect` will be inside the screen or not
    /// - Function's `screenSize` argument should be the result of the function: `getScreenSize()`
    // getScreenSize() is not in the internal of the function to make testing possible.
    pub fn ScreenRectFromRect(self: Camera, gameRect: Rect, screenSize: Size) ScreenRect {
        if (self.rect.size.w <= 0 or self.rect.size.h <= 0) unreachable;

        const widthScale = screenSize.w / self.rect.size.w;
        const heightScale = screenSize.h / self.rect.size.h;

        return .{
            .pos = .{
                .x = @intFromFloat(@ceil((gameRect.pos.x - self.rect.pos.x) * widthScale)),
                .y = @intFromFloat(@ceil((gameRect.pos.y - self.rect.pos.y) * heightScale)),
            },
            .size = .{
                .w = @intFromFloat(@ceil(gameRect.size.w * widthScale)),
                .h = @intFromFloat(@ceil(gameRect.size.h * heightScale)),
            },
        };
    }

    /// Is used to figure out where a mouse-click happend in the game's world.
    /// - Function shall calculate where the screen input `x` and `y` happened in the game world
    /// - Function's `screenPos` argument should be the result of the function: `rl.getMousePosition()`
    /// - Function's `screenSize` argument should be the result of the function: `getScreenSize()`
    // getScreenSize() is not in the internal of the function to make testing possible.
    pub fn Pos2FromScreenPos(self: Camera, screenPos: rl.Vector2, screenSize: Size) Pos2 {
        if (self.rect.size.w <= 0 or self.rect.size.h <= 0) unreachable;

        const widthScale = screenSize.w / self.rect.size.w;
        const heightScale = screenSize.h / self.rect.size.h;

        return .{
            .x = (screenPos.x / widthScale) + self.rect.pos.x,
            .y = (screenPos.y / heightScale) + self.rect.pos.y,
        };
    }
};

// ==========================================================================
const testing = @import("std").testing;
const FLOAT_TOLERANCE = 0.001;

test "camera_focus_on" {
    var camera = Camera{ .rect = .{
        .pos = .{ .x = 0, .y = 0 },
        .size = .{
            .w = 300,
            .h = 180,
        },
    } };

    for (0..50) |i| {
        for (0..50) |j| {
            const pos = Pos2{
                .x = (@as(f32, @floatFromInt(j)) - 25) * 100,
                .y = (@as(f32, @floatFromInt(i)) - 25) * 100,
            };

            camera.focusOn(pos);

            const mid = camera.rect.getMidPoint();

            try testing.expectApproxEqRel(pos.x, mid.x, FLOAT_TOLERANCE);
            try testing.expectApproxEqRel(pos.y, mid.y, FLOAT_TOLERANCE);
        }
    }
}

test "camera_draw_location" {
    const screenSize = Size{ .w = 800, .h = 450 };
    var camera = Camera{ .rect = .{
        .pos = .{ .x = 0, .y = 0 },
        .size = .{
            .w = 800,
            .h = 450,
        },
    } };

    const r1 = Rect{
        .pos = .{ .x = 20, .y = 50 },
        .size = .{ .w = 50, .h = 70 },
    };
    var screenRect = camera.ScreenRectFromRect(r1, screenSize);

    try testing.expectEqual(@as(i32, @intFromFloat(r1.pos.x)), screenRect.pos.x);
    try testing.expectEqual(@as(i32, @intFromFloat(r1.pos.y)), screenRect.pos.y);
    try testing.expectEqual(@as(i32, @intFromFloat(r1.size.w)), screenRect.size.w);
    try testing.expectEqual(@as(i32, @intFromFloat(r1.size.h)), screenRect.size.h);

    camera.rect.size.w /= 2;
    camera.rect.size.h /= 2;
    screenRect = camera.ScreenRectFromRect(r1, screenSize);

    try testing.expectEqual(@as(i32, @intFromFloat(r1.pos.x * 2)), screenRect.pos.x);
    try testing.expectEqual(@as(i32, @intFromFloat(r1.pos.y * 2)), screenRect.pos.y);
    try testing.expectEqual(@as(i32, @intFromFloat(r1.size.w * 2)), screenRect.size.w);
    try testing.expectEqual(@as(i32, @intFromFloat(r1.size.h * 2)), screenRect.size.h);

    camera.rect.size.w *= 4;
    camera.rect.size.h *= 4;
    screenRect = camera.ScreenRectFromRect(r1, screenSize);

    try testing.expectEqual(@as(i32, @intFromFloat(r1.pos.x / 2)), screenRect.pos.x);
    try testing.expectEqual(@as(i32, @intFromFloat(r1.pos.y / 2)), screenRect.pos.y);
    try testing.expectEqual(@as(i32, @intFromFloat(r1.size.w / 2)), screenRect.size.w);
    try testing.expectEqual(@as(i32, @intFromFloat(r1.size.h / 2)), screenRect.size.h);
}

test "camera_mouse_click" {
    const screenSize = Size{ .w = 800, .h = 450 };
    var camera = Camera{ .rect = .{
        .pos = .{ .x = 0, .y = 0 },
        .size = .{
            .w = 800,
            .h = 450,
        },
    } };

    var mousePos = rl.Vector2{ .x = 0, .y = 0 };
    var pos = camera.Pos2FromScreenPos(mousePos, screenSize);

    try testing.expectApproxEqRel(mousePos.x, pos.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(mousePos.y, pos.y, FLOAT_TOLERANCE);

    mousePos.x = 20;
    mousePos.y = 50;
    pos = camera.Pos2FromScreenPos(mousePos, screenSize);
    try testing.expectApproxEqRel(mousePos.x, pos.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(mousePos.y, pos.y, FLOAT_TOLERANCE);

    camera.rect.pos.x += 100;
    camera.rect.pos.y -= 30;
    pos = camera.Pos2FromScreenPos(mousePos, screenSize);
    try testing.expectApproxEqRel(120, pos.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(20, pos.y, FLOAT_TOLERANCE);

    camera.rect.size.w /= 2;
    camera.rect.size.h /= 2;
    pos = camera.Pos2FromScreenPos(mousePos, screenSize);
    try testing.expectApproxEqRel(110, pos.x, FLOAT_TOLERANCE);
    try testing.expectApproxEqRel(-5, pos.y, FLOAT_TOLERANCE);
}
