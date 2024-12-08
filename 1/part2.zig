const std = @import("std");

pub fn main() !void {
    var file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var reader = file.reader();
    var output: [100]u8 = undefined;
    var output_fbs = std.io.fixedBufferStream(&output);
    const writer = output_fbs.writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var list1 = std.ArrayList(i32).init(allocator);
    defer list1.deinit();
    var map = std.AutoHashMap(i32, i32).init(allocator);
    defer map.deinit();

    while (true) {
        reader.streamUntilDelimiter(writer, '\n', null) catch |err| {
            switch (err) {
                error.EndOfStream => {
                    output_fbs.reset(); // clear buffer before exit
                    break;
                }, // file read till the end
                else => {
                    std.debug.print("Error while reading file: {any}\n", .{err});
                    return err;
                },
            }
        };

        const line = output_fbs.getWritten();
        std.debug.print("Line: {s}\n", .{line});
        var split = std.mem.splitSequence(u8, line, "   ");

        // TODO
        const on = split.next().?;
        const tw = split.next().?;
        const one: i32 = try std.fmt.parseInt(i32, on, 10);
        const two: i32 = try std.fmt.parseInt(i32, tw, 10);

        try list1.append(one);

        const val = map.get(two) orelse 0;

        try map.put(two, val + 1);

        // since steamUntilDelimiter keeps appending the read bytes to the buffer
        // we should clear it on every iteration so that only individual lines are
        // displayed on each iteration.
        output_fbs.reset();
    }

    var similarity_score: i32 = 0;

    for (list1.items) |item| {
        const val = map.get(item) orelse 0;
        similarity_score += item * val;
    }

    std.debug.print("Similarity score: {d}\n", .{similarity_score});

    std.debug.print("Hello, {s}!\n", .{"World"});
}
