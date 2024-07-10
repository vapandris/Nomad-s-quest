const std = @import("std");
const rl = @import("raylib");
const assets = @import("assets.zig");
const atlas = @import("Base/atlas.zig");
const math = @import("Base/math.zig");
const shapes = @import("Base/shapes.zig");
const screen = @import("Base/screen.zig");
const timer = @import("Base/timer.zig");

pub const Ghoul = struct {
    hitCircle: shapes.Circle,
    moveDirection: math.Vec2 = .{ .x = 0, .y = 0 },
    speed: f32 = 150,

    frameCounter: u8 = 0,

    pub fn move(self: *Ghoul, target: ?math.Pos2, frameDelta: f32) void {
        if (target == null) return;

        self.moveDirection = self.hitCircle.pos.getVectorTo(target.?);
        if (self.moveDirection.getLength() != 0) self.moveDirection.normalize();

        const dir = self.moveDirection;
        const speed = self.speed;
        self.hitCircle.vel.x += dir.x * speed * frameDelta;
        self.hitCircle.vel.y += dir.y * speed * frameDelta;

        self.hitCircle.move(frameDelta);
    }

    pub fn draw(self: *Ghoul) void {
        const frameArray = assets.ghoulAtlas.map.get("ghoul-run-front").?;

        if (assets.animationTimerElapsed) {
            self.frameCounter += 1;

            if (self.frameCounter >= frameArray.items.len) {
                self.frameCounter = 0;
            }
        }

        // define a rect where we should draw to:
        var rect = shapes.Rect{
            .pos = undefined,
            .size = .{ .w = self.hitCircle.r * 2, .h = self.hitCircle.r * 2 },
        };
        rect.setMidPoint(self.hitCircle.pos);

        const screenRect = assets.camera.ScreenRectFromRect(rect, screen.getScreenSize());

        rl.drawTexturePro(
            assets.ghoulTextr,
            frameArray.items[self.frameCounter],
            screenRect,
            .{ .x = 0, .y = 0 },
            0,
            rl.Color.white,
        );
    }
};
