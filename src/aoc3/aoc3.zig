const std = @import("std");
const shared = @import("../shared.zig");

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    var input = try std.fs.cwd().readFileAlloc(allocator, "src/aoc3/input.txt", 100000);
    defer allocator.free(input);
    var sum: u64 = 0;
    var sum_with_enable: u64 = 0;
    var enabled: bool = true;
    while (input.len != 0) {
        if (shared.isPrefixed("do()", input)) |remaining| {
            enabled = true;
            input = remaining;
        }
        if (shared.isPrefixed("don't()", input)) |remaining| {
            enabled = false;
            input = remaining;
        }
        input = shared.isPrefixed("mul(", input) orelse {
            input = input[1..];
            continue;
        };
        const first_num = shared.getPrefixedNumber(input) orelse {
            input = input[1..];
            continue;
        };

        input = shared.isPrefixed(",", first_num.rest) orelse {
            input = input[1..];
            continue;
        };

        const second_num = shared.getPrefixedNumber(input) orelse {
            input = input[1..];
            continue;
        };

        input = shared.isPrefixed(")", second_num.rest) orelse {
            input = input[1..];
            continue;
        };

        sum += first_num.number * second_num.number;
        sum_with_enable += if (enabled) first_num.number * second_num.number else 0;
    }

    std.debug.print("Day 3 Part 1: {}\n", .{sum});
    std.debug.print("Day 3 Part 2: {}\n", .{sum_with_enable});
}
