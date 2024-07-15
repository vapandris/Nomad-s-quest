const rl = @import("raylib");
const assets = @import("assets.zig");
const atlas = @import("Base/atlas.zig");
const math = @import("Base/math.zig");
const shapes = @import("Base/shapes.zig");
const screen = @import("Base/screen.zig");

const NomadState = union(enum) {
    idle,
    run,
};

pub const Nomad = struct {
    hitCircle: shapes.Circle,
    moveDirection: math.Vec2 = .{ .x = 0, .y = 0 },

    frameCounter: u8 = 0,
    state: NomadState = .idle,

    const maxSpeed: f32 = 10;
    const acceleration: f32 = 2.5;
    const deceleration = acceleration / 2;

    pub fn update(self: *Nomad, frameDelta: f32) void {
        self.moveDirection.normalize();
        const dir = self.moveDirection;
        const FPS = 60.0;

        self.hitCircle.move(
            dir,
            (acceleration * FPS),
            (deceleration * FPS),
            maxSpeed,
            frameDelta,
        ) catch unreachable;
    }

    pub fn draw(self: *Nomad) void {
        var frameArray: atlas.AnimationFrames = undefined;

        switch (self.state) {
            .idle => {
                frameArray = assets.nomadAtlas.map.get("nomad-run-front").?;
            },
            .run => {},
        }

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
            assets.nomadTextr,
            frameArray.items[self.frameCounter],
            screenRect,
            .{ .x = 0, .y = 0 },
            0,
            rl.Color.white,
        );
    }
};
