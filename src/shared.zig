const std = @import("std");

pub fn isPrefixed(needle: []const u8, haystack: []u8) ?[]u8 {
    if (std.mem.startsWith(u8, haystack, needle)) {
        return haystack[needle.len..];
    }
    return null;
}

pub const NumberResult = struct {
    number: u64,
    rest: []u8,
};

pub fn getPrefixedNumber(haystack: []u8) ?NumberResult {
    var number: u64 = 0;
    var i: usize = 0;
    while (i < haystack.len) {
        if (haystack[i] < '0' or haystack[i] > '9') {
            break;
        }

        number *= 10;
        number += @intCast(haystack[i] - '0');
        i += 1;
    }

    return .{ .number = number, .rest = haystack[i..] };
}
