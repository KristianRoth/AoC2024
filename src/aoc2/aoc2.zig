const std = @import("std");

fn custom_check(_: void, a: i32, b: i32) bool {
    return !(1 <= @abs(a - b) and @abs(a - b) <= 3);
}

fn check_sequense(items: []i32) bool {
    return (std.sort.isSorted(i32, items, {}, std.sort.asc(i32)) or
        std.sort.isSorted(i32, items, {}, std.sort.desc(i32))) and
        std.sort.isSorted(i32, items, {}, custom_check);
}

fn loose_Check_sequense(items: []i32) bool {
    for (0..items.len) |i| {
        const to_swap = items[i];
        items[i] = items[0];
        items[0] = to_swap;
        const one_removed = items[1..];
        if (check_sequense(one_removed)) {
            return true;
        }
    }
    return false;
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const input = try std.fs.cwd().readFileAlloc(allocator, "src/aoc2/input.txt", 100000);
    defer allocator.free(input);

    var lines = std.mem.split(u8, input, "\n");
    var count: i32 = 0;
    var loose_count: i32 = 0;

    while (lines.next()) |line| {
        var numbers_strs = std.mem.split(u8, line, " ");
        var numbers = std.ArrayList(i32).init(allocator);
        defer numbers.deinit();
        while (numbers_strs.next()) |number_str| {
            const number = try std.fmt.parseInt(i32, number_str, 10);
            try numbers.append(number);
        }

        if (check_sequense(numbers.items)) {
            count += 1;
            loose_count += 1;
            continue;
        }

        if (loose_Check_sequense(numbers.items)) {
            loose_count += 1;
        }
    }

    std.debug.print("Day 2 Part 1: {}\n", .{count});
    std.debug.print("Day 2 Part 2: {}\n", .{loose_count});
}
