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

    pub fn focusOn(self: *Camera, pos: Pos2) void {
        const midleOfCamera = self.rect.getMidPoint();

        const delta = midleOfCamera.getVectorTo(pos);

        self.*.rect.pos.x += delta.x;
        self.*.rect.pos.y += delta.y;
    }

    /// A rectangle on the screen.
    /// It is returned by `Camera` when figuring out where to draw a rectangle in the game.
    /// Should only be used when it is returned, thus it is not public.
    const ScreenRect = struct {
        pos: struct { x: i32, y: i32 },
        size: struct { w: i32, h: i32 },
    };
};

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
