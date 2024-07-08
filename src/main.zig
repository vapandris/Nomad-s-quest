const rl = @import("raylib");
const std = @import("std");
const assets = @import("assets.zig");
const nomad = @import("nomad.zig");
const timer = @import("Base/timer.zig");
const math = @import("Base/math.zig");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    assets.init(gpa.allocator());
    defer assets.deinit();

    var player = nomad.Nomad{
        .hitCircle = .{
            .r = 64,
            .pos = .{ .x = 30, .y = 50 },
        },
        //.timer = timer.RepeateTimer.start(150),
    };

    while (!rl.windowShouldClose()) {
        assets.loopAnimationTimer();

        const speed = 48;
        var dir = math.Vec2.ZERO;

        if (rl.isKeyDown(.key_d)) dir.x += 1;
        if (rl.isKeyDown(.key_a)) dir.x -= 1;
        if (rl.isKeyDown(.key_s)) dir.y += 1;
        if (rl.isKeyDown(.key_w)) dir.y -= 1;

        if (dir.getLength() > 0) dir.normalize();

        player.hitCircle.vel.x += dir.x * speed * rl.getFrameTime();
        player.hitCircle.vel.y += dir.y * speed * rl.getFrameTime();

        player.hitCircle.move(@floatFromInt(speed / 10), rl.getFrameTime());

        if (rl.getMouseWheelMove() > 0) assets.camera.zoom(rl.getFrameTime(), .in);
        if (rl.getMouseWheelMove() < 0) assets.camera.zoom(rl.getFrameTime(), .out);

        rl.beginDrawing();
        defer rl.endDrawing();

        player.draw();

        rl.clearBackground(rl.Color.white);
    }
}
// ==========================================================================
const testing = std.testing;

test "main" {
    _ = @import("Base/math.zig");
    _ = @import("Base/shapes.zig");
    _ = @import("Base/screen.zig");
    _ = @import("Base/atlas.zig");
}
