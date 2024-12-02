const std = @import("std");

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try std.fs.cwd().readFileAlloc(allocator, "src/aoc1/input.txt", 100000);
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var numbers1 = std.ArrayList(i64).init(allocator);
    var numbers2 = std.ArrayList(i64).init(allocator);

    while (lines.next()) |line| {
        var nums = std.mem.split(u8, line, "   ");

        try numbers1.append(try std.fmt.parseInt(i64, nums.next().?, 10));
        try numbers2.append(try std.fmt.parseInt(i64, nums.next().?, 10));
    }

    std.mem.sort(i64, numbers1.items, {}, std.sort.asc(i64));
    std.mem.sort(i64, numbers2.items, {}, std.sort.asc(i64));

    var sum: u64 = 0;
    for (0..numbers1.items.len) |i| {
        sum += @abs(numbers2.items[i] - numbers1.items[i]);
    }

    std.debug.print("Day 1 Part 1: {}\n", .{sum});

    var occurances = std.AutoHashMap(i64, i64).init(allocator);
    defer occurances.deinit();

    for (numbers2.items) |item| {
        try occurances.put(item, (occurances.get(item) orelse 0) + 1);
    }

    var sum2: i64 = 0;
    for (numbers1.items) |item| {
        sum2 += item * (occurances.get(item) orelse 0);
    }

    std.debug.print("Day 1 Part 2: {}\n", .{sum2});
}
