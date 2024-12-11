const std = @import("std");
const shared = @import("../shared.zig");

fn calcCheckSum(input: []u8) u64 {
    var checksum: u64 = 0;

    var checksumCount: u64 = 0;
    var start: usize = 0;
    var end = input.len - 1;
    while (true) {
        for (0..input[start]) |_| {
            checksum += (@divExact(start, 2)) * checksumCount;
            checksumCount += 1;
        }
        const fromEnd = input[start + 1];
        start += 2;
        if (start > end) {
            break;
        }
        for (0..fromEnd) |_| {
            checksum += (@divExact(end, 2)) * checksumCount;
            checksumCount += 1;
            input[end] -= 1;
            if (input[end] == 0) {
                end -= 2;
            }
        }
        if (start > end) {
            break;
        }
    }
    return checksum;
}

fn calcChecksum2(input: []u8) u64 {
    var checksum: u64 = 0;
    var checksumCount: u64 = 0;
    var start: usize = 0;
    while (true) {
        if (input[start] >= 10) {
            checksumCount += input[start] - 10;
        } else {
            for (0..input[start]) |_| {
                checksum += (@divExact(start, 2)) * checksumCount;
                checksumCount += 1;
            }
        }
        if (start + 1 >= input.len) {
            break;
        }
        var fromEnd = input[start + 1];
        while (fromEnd > 0) {
            var endNum: u8 = 0;
            var end = input.len - 1;
            while (end > start) {
                if (input[end] <= fromEnd and input[end] != 0) {
                    endNum = input[end];
                    input[end] += 10;

                    break;
                }
                end -= 2;
            }
            if (endNum == 0) {
                checksumCount += fromEnd - endNum;
                break;
            }
            for (0..endNum) |_| {
                checksum += (@divExact(end, 2)) * checksumCount;
                checksumCount += 1;
            }
            fromEnd -= endNum;
        }
        start += 2;
    }
    return checksum;
}

pub fn solve() !void {
    const allocator = std.heap.page_allocator;
    const inputM = try shared.readToCharSlice("src/aoc9/input.txt", allocator);
    var input = try allocator.alloc(u8, inputM[0].len);
    for (inputM[0], 0..) |c, i| {
        input[i] = c - 48;
    }

    const checksum = calcCheckSum(input);

    // Restore input
    for (inputM[0], 0..) |c, i| {
        input[i] = c - 48;
    }

    const checksum2 = calcChecksum2(input);

    std.debug.print("Day 9 Part 1: {d}\n", .{checksum});
    std.debug.print("Day 9 Part 2: {d}\n", .{checksum2});
}
