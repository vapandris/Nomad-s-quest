const rl = @import("raylib");
const std = @import("std");
const atlas = @import("Base/atlas.zig");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const nomadSprite = rl.loadTexture("assets/nomad.png");

    if (nomadSprite.id <= 0) {
        std.debug.panic("COULDN'T OPEN ASSET!!!\n", .{});
    }
    var frameCounter: u8 = 0;

    var frameDelayCounter: u32 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var nomadAssets = atlas.AtlasLibrary.init(gpa.allocator());
    defer nomadAssets.deinit();

    try nomadAssets.parse("assets/nomad.rtpa");

    while (!rl.windowShouldClose()) : (frameDelayCounter += 1) {
        const currentAnimation = nomadAssets.map.get("nomad-idle-back") orelse std.debug.panic("Couldn't find 'idle-front' animation of nomad!!", .{});
        // should use a proper timer later.
        if (frameDelayCounter == 10) {
            frameDelayCounter = 0;
            frameCounter += 1;
            if (frameCounter == currentAnimation.items.len) {
                frameCounter = 0;
            }
        }

        const animationData = currentAnimation.items[frameCounter];

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        rl.drawTexturePro(
            nomadSprite,
            animationData,
            .{ .x = 10, .y = 10, .width = 32 * 5.0, .height = 32 * 5.0 },
            .{ .x = 0, .y = 0 },
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
    _ = @import("Base/atlas.zig");
}
