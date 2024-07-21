const math = @import("Base/math.zig");

const Level = struct {
    map: [][]const u8,
    pos: math.Pos2 = .{ .x = 0, .y = 0 },

    const tileSize = 32;

    pub fn columnsCount(self: Level) u32 {
        return @intCast(self.map[0].len);
    }

    pub fn rowsCount(self: Level) u32 {
        return @intCast(self.map.len);
    }

    pub fn width(self: Level) f32 {
        return @floatFromInt(tileSize * self.columnsCount());
    }

    pub fn height(self: Level) f32 {
        return @floatFromInt(tileSize * self.rowsCount());
    }

    pub fn getGamePosition(self: Level, column: u32, row: u32) math.Pos2 {
        if (self.columnsCount() <= column) unreachable;
        if (self.rowsCount() <= row) unreachable;

        return .{
            .x = self.pos.x + @as(f32, @floatFromInt(column * tileSize)),
            .y = self.pos.y + @as(f32, @floatFromInt(row * tileSize)),
        };
    }

    pub fn getIndexFromPos(self: Level, position: math.Pos2) ?struct { column: u32, row: u32 } {
        if (position.x < self.pos.x) return null;
        if (position.x > self.pos.x + self.width()) return null;
        if (position.y < self.pos.y) return null;
        if (position.y > self.pos.y + self.height()) return null;

        return .{
            .column = @intFromFloat((position.x - self.pos.x) / tileSize),
            .row = @intFromFloat((position.y - self.pos.y) / tileSize),
        };
    }

    pub fn getTile(self: Level, column: u32, row: u32) ?u8 {
        if (0 <= column and column < self.columnsCount() and
            0 <= row and row < self.rowsCount())
        {
            return self.map[row][column];
        }

        return null;
    }
};

// ==========================================================================
const testing = @import("std").testing;

test Level {
    const map = [_][]const u8{
        "##################  #####",
        "####~~############  #####",
        "#####~~#####......  x####",
        "####~~~~..........  xx###",
        "##~~~~~~~~........  xxx##",
        "#~~~~~~~~.....      .xx##",
        "#~~~~~~~~....   ... ..x##",
        "#~~~~~~~~...x  .......xx#",
        "#..~~~~~...xx  ....xx..x#",
        "#..~~~~~...xx  ...xx...x#",
        "#..~~~~~.....  .......x##",
        "##~~~~~.....  ...xxxxxx##",
        "###~~~.....  ..xxxxxxx###",
        "##########xxxxxxxxxx#####",
        "#########################",
    };

    var level = Level{ .map = @constCast(&map) };
    const p1 = math.Pos2{ .x = 330, .y = 10 };
    const p2 = math.Pos2{ .x = -10, .y = 70 };

    try testing.expectEqual(15, level.rowsCount());
    try testing.expectEqual(25, level.columnsCount());
    try testing.expectEqual(800, level.width());
    try testing.expectEqual(480, level.height());

    var pos = level.getGamePosition(2, 5);
    try testing.expectEqual(64, pos.x);
    try testing.expectEqual(160, pos.y);

    var index = level.getIndexFromPos(p1);
    try testing.expectEqual(10, index.?.column);
    try testing.expectEqual(0, index.?.row);
    index = level.getIndexFromPos(p2);
    try testing.expectEqual(null, index);

    level.pos = .{ .x = -20, .y = 30 };

    pos = level.getGamePosition(2, 5);
    try testing.expectEqual(44, pos.x);
    try testing.expectEqual(190, pos.y);

    index = level.getIndexFromPos(p1);
    try testing.expectEqual(null, index);
    index = level.getIndexFromPos(p2);
    try testing.expectEqual(0, index.?.column);
    try testing.expectEqual(1, index.?.row);

    if (level.getTile(10, 11)) |char| {
        try testing.expectEqual('.', char);
    }
    try testing.expectEqual(null, level.getTile(level.columnsCount(), 0));
    try testing.expectEqual(null, level.getTile(0, level.rowsCount()));
}
