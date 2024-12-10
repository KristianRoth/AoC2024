const std = @import("std");
const shared = @import("../shared.zig");

const Vec2 = struct {
    x: i32,
    y: i32,
};

fn addAntiNode(isAntiNode: []bool, x: i32, y: i32, width: usize) bool {
    if (0 > x or x >= width or 0 > y or y >= width) {
        return false;
    }
    const idx = @as(usize, @intCast(y)) * width + @as(usize, @intCast(x));
    if (isAntiNode[idx]) {
        return false;
    }
    isAntiNode[idx] = true;
    return true;
}

fn addTAntiNode(isAntiNode: []bool, xStart: i32, dx: i32, yStart: i32, dy: i32, width: usize) u32 {
    var count: u32 = 0;
    var x = xStart;
    var y = yStart;
    while (0 <= x and x < width and 0 <= y and y < width) {
        if (addAntiNode(isAntiNode, x, y, width)) {
            count += 1;
        }
        x += dx;
        y += dy;
    }
    return count;
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try shared.readToCharSlice("src/aoc8/input.txt", allocator);
    var antennas = std.AutoHashMap(u8, *std.ArrayList(*Vec2)).init(allocator);
    const isAntiNode = try allocator.alloc(bool, input.len * input[0].len);
    const isTAntiNode = try allocator.alloc(bool, input.len * input[0].len);
    defer {
        allocator.free(input);
        allocator.free(isAntiNode);
        allocator.free(isTAntiNode);
        antennas.deinit();
    }
    for (input, 0..) |line, y| {
        for (line, 0..) |c, x| {
            if (c == '.') {
                continue;
            }
            const antenna = try allocator.create(Vec2);
            antenna.* = .{ .x = @intCast(x), .y = @intCast(y) };
            var list = antennas.get(c);
            if (list == null) {
                var newList = try allocator.create(std.ArrayList(*Vec2));
                newList.* = std.ArrayList(*Vec2).init(allocator);
                try newList.append(antenna);
                try antennas.put(c, newList);
            } else {
                try list.?.append(antenna);
            }
        }
    }

    var count: u32 = 0;
    var countT: u32 = 0;
    var iter = antennas.iterator();
    while (iter.next()) |entry| {
        for (entry.value_ptr.*.*.items, 0..) |antenna1, i| {
            for (entry.value_ptr.*.*.items[i + 1 ..]) |antenna2| {
                const dx = antenna1.x - antenna2.x;
                const dy = antenna1.y - antenna2.y;
                if (addAntiNode(isAntiNode, antenna1.x + dx, antenna1.y + dy, input.len)) {
                    count += 1;
                }

                if (addAntiNode(isAntiNode, antenna2.x - dx, antenna2.y - dy, input.len)) {
                    count += 1;
                }
                countT += addTAntiNode(isTAntiNode, antenna1.x, dx, antenna1.y, dy, input.len);
                countT += addTAntiNode(isTAntiNode, antenna2.x, -dx, antenna2.y, -dy, input.len);
            }
        }
    }
    std.debug.print("Day 8 Part 1: {}\n", .{count});
    std.debug.print("Day 8 Part 2: {}\n", .{countT});
}
