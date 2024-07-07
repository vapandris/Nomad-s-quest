const rl = @import("raylib");
const std = @import("std");
const assets = @import("assets.zig");
const nomad = @import("nomad.zig");
const timer = @import("Base/timer.zig");

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
        .hitBox = .{
            .r = 64,
            .pos = .{ .x = 30, .y = 50 },
        },
        .timer = timer.RepeateTimer.start(150),
    };

    while (!rl.windowShouldClose()) {
        if (rl.isKeyDown(.key_d)) player.hitBox.pos.x += 50 * rl.getFrameTime();
        if (rl.isKeyDown(.key_a)) player.hitBox.pos.x -= 50 * rl.getFrameTime();
        if (rl.isKeyDown(.key_s)) player.hitBox.pos.y += 50 * rl.getFrameTime();
        if (rl.isKeyDown(.key_w)) player.hitBox.pos.y -= 50 * rl.getFrameTime();

        if (rl.getMouseWheelMove() > 0) assets.camera.zoom(rl.getFrameTime(), .in);
        if (rl.getMouseWheelMove() < 0) assets.camera.zoom(rl.getFrameTime(), .out);

        rl.beginDrawing();
        defer rl.endDrawing();

        player.draw();

        rl.clearBackground(rl.Color.white);

        assets.loopAnimationTimer();
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
