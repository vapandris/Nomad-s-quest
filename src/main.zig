const rl = @import("raylib");
const std = @import("std");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const frameCount: f32 = 4;
    const nomadIdle = rl.loadTexture("assets/nomad-idle-front.png");
    const frameWidth: f32 = @as(f32, @floatFromInt(nomadIdle.width)) / frameCount;
    const frameHeight: f32 = @floatFromInt(nomadIdle.height);
    const frameScaler = 5.0;
    var frameCounter: f32 = 0;

    var frameDelayCounter: u32 = 0;

    while (!rl.windowShouldClose()) : (frameDelayCounter += 1) {
        // should use a proper timer later.
        if (frameDelayCounter == 10) {
            frameDelayCounter = 0;
            frameCounter += 1.0;
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        rl.drawTexturePro(
            nomadIdle,
            .{ .x = frameCounter * frameWidth, .y = 0, .width = frameWidth, .height = frameHeight },
            .{ .x = 10, .y = 10, .width = frameWidth * frameScaler, .height = frameHeight * frameScaler },
            .{ .x = 32, .y = 0 },
            0,
            rl.Color.white,
        );
    }
}
// ==========================================================================
const testing = std.testing;

test "main" {
    _ = @import("Base/math.zig");
    _ = @import("Base/shapes.zig");
    _ = @import("Base/screen.zig");
}
