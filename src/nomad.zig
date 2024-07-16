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

const FaceDirection = union(enum) { up, down, left, right };

pub const Nomad = struct {
    hitCircle: shapes.Circle,
    moveDirection: math.Vec2 = .{ .x = 0, .y = 0 },
    faceDirection: FaceDirection = .down,

    frameCounter: u8 = 0,
    state: NomadState = .idle,

    const maxSpeed: f32 = 10;
    const acceleration: f32 = 2.5;
    const deceleration = acceleration / 2;

    pub fn getPositionForCameraToFollow(self: Nomad) math.Pos2 {
        const faceing = self.faceDirection;
        const distance: f32 = self.hitCircle.r * 2;
        const dir = math.Pos2{
            .x = distance * @as(f32, switch (faceing) {
                .left => -1,
                .right => 1,
                else => 0,
            }),
            .y = distance * @as(f32, switch (faceing) {
                .up => -1,
                .down => 1,
                else => 0,
            }),
        };

        return .{
            .x = self.hitCircle.pos.x + dir.x,
            .y = self.hitCircle.pos.y + dir.y,
        };
    }

    pub fn update(self: *Nomad, frameDelta: f32) void {
        // Update movement:
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

        // Update face-direction:
        self.faceDirection =
            if (dir.x > 0) .right else if (dir.x < 0) .left else if (dir.y > 0) .down else if (dir.y < 0) .up else self.faceDirection;
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

        // Debug draw:
        const posToFollow = self.getPositionForCameraToFollow();
        const circle = assets.camera.ScreenCircleFromCircle(.{
            .pos = posToFollow,
            .r = 10,
        }, screen.getScreenSize());

        rl.drawCircle(circle.x, circle.y, circle.r, rl.Color.black);
    }
};
