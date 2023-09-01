const std = @import("std");
const createCanvas = @import("./lib.zig").createCanvas;

pub fn main() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const width = 1000;
    const height = 1000;
    var canvas = try createCanvas(width, height, .rgba, allocator);
    canvas.fillStyle = 0x20f0f0ff;
    canvas.fillCanvas();

    canvas.fillStyle = 0x10e010ff;
    canvas.fillRect(0, 0, 1000, 200);

    const filePath: []const u8 = "/mnt/c/Users/Utilisateur/Desktop/file.bmp";
    canvas.save(filePath) catch {
        std.debug.print("{s}\n", .{"File does not exist"});
    };
    // std.debug.print("{any}\n", .{canvas});

    return 0;
}
