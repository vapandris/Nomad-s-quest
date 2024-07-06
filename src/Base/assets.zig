const std = @import("std");
const rl = @import("raylib");

const AnimationData = std.ArrayList(rl.Rectangle);

const AssetLibrary = struct {
    map: std.StringHashMap(AnimationData),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) AssetLibrary {
        return .{
            .allocator = allocator,
            .map = std.StringHashMap(AnimationData).init(allocator),
        };
    }

    pub fn deinit(self: *AssetLibrary) void {
        var it = self.map.iterator();

        while (it.next()) |data| {
            data.value_ptr.deinit();
        }
        self.map.deinit();
    }

    pub fn parse(self: *AssetLibrary, comptime rtpaFile: []const u8) !void {
        const in = try std.fs.cwd().openFile(rtpaFile, .{});
        var bufferReader = std.io.bufferedReader(in.reader());
        var reader = bufferReader.reader();

        var msgBuf: [0xFF]u8 = undefined;
        while (try reader.readUntilDelimiterOrEof(&msgBuf, '\n')) |line| {
            if (line.len == 0 or line[0] != 's') continue;

            var it = std.mem.split(u8, line, " ");

            // get the starting s:
            _ = it.next();

            // get the nameId:
            var nameId = it.next() orelse return ParseError.NameIdMissing;

            // remove the 'Id' from nameId:
            var idx = nameId.len - 1;
            while (0 <= idx) : (idx -= 1) {
                const char = nameId[idx];

                if ('0' <= char and char <= '9') {
                    nameId.len -= 1;
                } else break;
            }

            const origin = rl.Vector2{
                .x = try std.fmt.parseFloat(f32, it.next().?),
                .y = try std.fmt.parseFloat(f32, it.next().?),
            };
            const pos = rl.Vector2{
                .x = try std.fmt.parseFloat(f32, it.next().?),
                .y = try std.fmt.parseFloat(f32, it.next().?),
            };
            const size = rl.Vector2{
                .x = try std.fmt.parseFloat(f32, it.next().?),
                .y = try std.fmt.parseFloat(f32, it.next().?),
            };
            const padding = try std.fmt.parseFloat(f32, it.next().?);

            // ignore all other inputs and hope it won't be a problem :)
            _ = origin;
            _ = padding;

            const rec = rl.Rectangle{
                .x = pos.x,
                .y = pos.y,
                .width = size.x,
                .height = size.y,
            };

            // If the given animation is already recorded, append to it, if not, create it.
            if (self.map.getEntry(nameId)) |entry| {
                try entry.value_ptr.append(rec);
            } else {
                var array = AnimationData.init(self.allocator);
                const key = try self.allocator.alloc(u8, nameId.len);
                @memcpy(key, nameId);
                try array.append(rec);
                try self.map.put(key, array);
            }
        }
    }

    const ParseError = error{
        NameIdMissing,
        UnexpectedValue,
    };
};

// ==========================================================================
const testing = @import("std").testing;
const FLOAT_TOLERANCE = 0.001;
test AssetLibrary {
    var a = AssetLibrary.init(std.heap.c_allocator);
    defer a.deinit();

    try a.parse("assets/nomad.rtpa");
    var it = a.map.iterator();
    while (it.next()) |entry| {
        std.debug.print("{s}: {any}\n", .{ entry.key_ptr.*, entry.value_ptr.*.items });
    }
    try testing.expect(true);
}
