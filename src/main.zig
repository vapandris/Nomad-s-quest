const rl = @import("raylib");
const std = @import("std");
const assets = @import("assets.zig");
const nomad = @import("nomad.zig");
const ghoul = @import("ghoul.zig");
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

    var player = nomad.Nomad{ .hitCircle = .{
        .r = 64,
        .pos = .{ .x = 30, .y = 50 },
    } };

    while (!rl.windowShouldClose()) {
        assets.loopAnimationTimer();

        var dir = math.Vec2.ZERO;

        if (rl.isKeyDown(.key_d)) dir.x += 1;
        if (rl.isKeyDown(.key_a)) dir.x -= 1;
        if (rl.isKeyDown(.key_s)) dir.y += 1;
        if (rl.isKeyDown(.key_w)) dir.y -= 1;

        player.moveDirection = dir;
        player.update(rl.getFrameTime());

        assets.camera.follow(player.getPositionForCameraToFollow(), 60, rl.getFrameTime());

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
