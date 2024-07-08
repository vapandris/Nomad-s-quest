const std = @import("std");
const rl = @import("raylib");
const atlas = @import("Base/atlas.zig");
const timer = @import("Base/timer.zig");
const screen = @import("Base/screen.zig");

pub var camera: screen.Camera = undefined;

var animationTimer: timer.RepeateTimer = undefined;
pub var animationTimerElapsed = false;

pub var nomadAtlas: atlas.AtlasLibrary = undefined;
pub var nomadTextr: rl.Texture = undefined;

pub fn init(allocator: std.mem.Allocator) void {
    animationTimer = timer.RepeateTimer.start(150);

    const screenSize = screen.getScreenSize();
    camera = .{
        .rect = .{
            .pos = .{ .x = 0, .y = 0 },
            .size = screenSize,
        },
    };

    nomadAtlas = atlas.AtlasLibrary.init(allocator);
    nomadAtlas.parse("assets/nomad.rtpa") catch |err| std.debug.panic("Error when parsing nomad.rtpa: {}\n", .{err});

    nomadTextr = rl.loadTexture("assets/nomad.png");
    if (nomadTextr.id <= 0) std.debug.print("Error when loading nomad.png\n", .{});
}

pub fn deinit() void {
    nomadAtlas.deinit();
}

/// Should only be called once each frame, either at the beginning or the end of the loop
pub fn loopAnimationTimer() void {
    animationTimerElapsed = animationTimer.loop();
}
