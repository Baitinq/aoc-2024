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
    var list2 = std.ArrayList(i32).init(allocator);
    defer list2.deinit();

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
        try list2.append(two);

        // since steamUntilDelimiter keeps appending the read bytes to the buffer
        // we should clear it on every iteration so that only individual lines are
        // displayed on each iteration.
        output_fbs.reset();
    }

    std.mem.sort(i32, list1.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, list2.items, {}, comptime std.sort.asc(i32));

    var total_distance: u32 = 0;

    var i: usize = 0;
    while (i < list1.items.len) {
        defer i += 1;
        const elem1 = list1.items[i];
        const elem2 = list2.items[i];

        const distance = @abs(elem2 - elem1);

        total_distance += distance;
    }

    std.debug.print("Total distance: {d}\n", .{total_distance});

    std.debug.print("Hello, {s}!\n", .{"World"});
}
