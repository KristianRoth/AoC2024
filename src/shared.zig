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

pub fn readToCharSlice(fileName: []const u8, allocator: std.mem.Allocator) ![][]const u8 {
    var file = try std.fs.cwd().openFile(fileName, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;

    var arrayList = std.ArrayList([]const u8).init(allocator);
    defer arrayList.deinit();
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const line_copy = try allocator.alloc(u8, line.len);
        std.mem.copyForwards(u8, line_copy, line);
        try arrayList.append(line_copy);
    }

    return arrayList.toOwnedSlice();
}

pub fn splitCharSlice(chars: []const u8, delim: []const u8) ![][]const u8 {
    var arrayList = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer arrayList.deinit();

    var start: usize = 0;
    for (0..chars.len - delim.len) |i| {
        if (std.mem.eql(u8, delim, chars[i .. i + delim.len])) {
            const slice = chars[start..i];
            try arrayList.append(slice);
            start = i + delim.len;
        }
    }

    if (start < chars.len) {
        const slice = chars[start..];
        try arrayList.append(slice);
    }

    return arrayList.toOwnedSlice();
}
