const std = @import("std");
const mem = std.mem;

const Headers = struct {
    store: std.StringHashMap(std.ArrayList([]const u8)),
    allocator: *mem.Allocator,

    const Self = @This();

    fn init(allocator: *mem.Allocator) Self {
        return .{
            .store = std.StringHashMap(std.ArrayList([]const u8)).init(allocator),
            .allocator = allocator,
        };
    }

    fn deinit(self: *Self) void {
        var it = self.store.iterator();

        while (it.next()) |entry| {
            entry.value.deinit();
            _ = self.store.remove(entry.key);
        }

        self.store.deinit();
        self.* = undefined;
    }

    pub fn format(
        self: Self,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        var it = self.store.iterator();

        while (it.next()) |entry| {
            for (entry.value.items) |v| {
                try writer.print("{s}:{s}\n", .{ entry.key, v });
            }
        }
    }

    pub fn add(self: *Self, key: []const u8, value: []const u8) !void {
        var l = self.store.get(key) orelse std.ArrayList([]const u8).init(self.allocator);
        try l.append(value);
        try self.store.put(key, l);
    }

    pub fn set(self: *Self, key: []const u8, value: []const u8) void {
        const l = std.ArrayList([]const u8).init(self.allocator);
        l.append(value);
        self.store.put(key, a);
    }

    pub fn get(self: *Self, key: []const u8) ?std.ArrayList([]const u8) {
        return self.store.get(key);
    }

    pub fn contains(self: *Self, key: []u8) bool {
        const val = self.store.contains(key);
    }
};

test "Header.add " {
    const testing = std.testing;
    const test_allocator = testing.allocator;

    var h = Headers.init(test_allocator);
    defer h.deinit();

    try h.add("test", "val1");
    try h.add("test", "val2");

    const l = h.get("test").?;
    testing.expectEqualSlices([]const u8, l.items, &[_][]const u8{ "val1", "val2" });
}

test "Header.format " {
    const testing = std.testing;
    const test_allocator = testing.allocator;

    var h = Headers.init(test_allocator);
    defer h.deinit();

    try h.add("test1", "val1");
    try h.add("test2", "val2");

    const header_string = try std.fmt.allocPrint(
        test_allocator,
        "{s}",
        .{h},
    );

    defer test_allocator.free(header_string);

    const test_header =
        \\test1:val1
        \\test2:val2
        \\
    ;

    testing.expectEqualStrings(header_string, test_header);
}
