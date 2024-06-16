const rl = @import("raylib");
const std = @import("std");

const screen = @import("Base/screen.zig");
const shapes = @import("Base/shapes.zig");

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    var camera = screen.Camera{
        .rect = .{
            .pos = .{ .x = 0, .y = 0 },
            .size = .{ .w = 800, .h = 450 },
        },
    };

    var cursosBall: ?shapes.Circle = null;

    const pillar1 = shapes.Rect{
        .pos = .{ .x = 0, .y = 0 },
        .size = .{ .w = 30, .h = 450 },
    };

    const pillar2 = shapes.Rect{
        .pos = .{ .x = 770, .y = 0 },
        .size = .{ .w = 30, .h = 450 },
    };

    while (!rl.windowShouldClose()) {
        if (rl.isKeyDown(.key_a)) {
            camera.rect.pos.x -= 150 * rl.getFrameTime();
        }
        if (rl.isKeyDown(.key_d)) {
            camera.rect.pos.x += 150 * rl.getFrameTime();
        }

        if (rl.isKeyDown(.key_c)) {
            if (cursosBall) |ball|
                camera.focusOn(ball.pos);
        }

        const mouseWheelMovement = rl.getMouseWheelMove();
        if (mouseWheelMovement > 0) { // upwards
            const widthDelta = (camera.rect.size.w * 1.5) * rl.getFrameTime();
            const heightDelta = (camera.rect.size.h * 1.5) * rl.getFrameTime();

            camera.rect.size.w += widthDelta;
            camera.rect.size.h += heightDelta;
            camera.rect.pos.x -= widthDelta / 2;
            camera.rect.pos.y -= heightDelta / 2;
        } else if (mouseWheelMovement < 0 and (camera.rect.size.w > 1 and camera.rect.size.h > 1)) { // downwards
            const widthDelta = (camera.rect.size.w * 1.5) * rl.getFrameTime();
            const heightDelta = (camera.rect.size.h * 1.5) * rl.getFrameTime();

            camera.rect.size.w -= widthDelta;
            camera.rect.size.h -= heightDelta;
            camera.rect.pos.x += widthDelta / 2;
            camera.rect.pos.y += heightDelta / 2;
        }

        if (rl.isMouseButtonDown(.mouse_button_left)) {
            const mouseScreenPos = rl.getMousePosition();
            const mouseGamePos = camera.Pos2FromScreenPos(mouseScreenPos, screen.getScreenSize());

            cursosBall = shapes.Circle{
                .pos = mouseGamePos,
                .r = 20,
            };
        }
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        const cameraPosText = try std.fmt.allocPrint(
            std.heap.c_allocator,
            "Camera pos is {d} {d}0",
            .{ camera.rect.pos.x, camera.rect.pos.y },
        );
        const cameraSizeText = try std.fmt.allocPrint(
            std.heap.c_allocator,
            "Camera size is {d} {d}0",
            .{ camera.rect.size.w, camera.rect.size.h },
        );
        const ballPosText = if (cursosBall != null) try std.fmt.allocPrint(
            std.heap.c_allocator,
            "Ball pos is {d} {d}0",
            .{ cursosBall.?.pos.x, cursosBall.?.pos.y },
        ) else try std.fmt.allocPrint(
            std.heap.c_allocator,
            "Ball pos is unknown0",
            .{},
        );

        // No way I have to do this:
        cameraPosText.ptr[cameraPosText.len - 1] = 0;
        cameraSizeText.ptr[cameraSizeText.len - 1] = 0;
        ballPosText.ptr[ballPosText.len - 1] = 0;

        if (cursosBall) |ball| {
            const screenCircle = camera.ScreenCircleFromCircle(ball, screen.getScreenSize());

            rl.drawCircle(screenCircle.x, screenCircle.y, screenCircle.r, rl.Color.black);
        }

        const screenPillar1 = camera.ScreenRectFromRect(pillar1, screen.getScreenSize());
        const screenPillar2 = camera.ScreenRectFromRect(pillar2, screen.getScreenSize());

        rl.drawRectangle(screenPillar1.pos.x, screenPillar1.pos.y, screenPillar1.size.w, screenPillar1.size.h, rl.Color.black);
        rl.drawRectangle(screenPillar2.pos.x, screenPillar2.pos.y, screenPillar2.size.w, screenPillar2.size.h, rl.Color.black);

        rl.drawText(@ptrCast(cameraPosText), 10, 10, 20, rl.Color.light_gray);
        rl.drawText(@ptrCast(cameraSizeText), 10, 40, 20, rl.Color.light_gray);
        rl.drawText(@ptrCast(ballPosText), 10, 70, 20, rl.Color.light_gray);
    }
}

// ==========================================================================
const testing = std.testing;

test "main" {
    _ = @import("Base/math.zig");
    _ = @import("Base/shapes.zig");
    _ = @import("Base/screen.zig");
}
