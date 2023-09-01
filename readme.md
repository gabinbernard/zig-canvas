# zig-canvas

A zig library to create, edit and export canvas.

## Getting started

And here's a "Hello world" zig-canvas program which creates a 100x100 canvas, draws a blue square at the middle and saves it as "./image.bmp":

```zig
const std = @import("std");
const createCanvas = @import("./lib.zig");

pub fn main() !u8 {
    // Create an allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Create a canvas and draw a 80x80 blue square    
    var canvas = try createCanvas(100, 100, .rgba, allocator);
    canvas.fillStyle = 0x0044ffff;
    canvas.fillRect(10, 10, 80, 80);

    // Save the canvas as a BMP image file on your file system
    const filePath: []const u8 = "image.bmp";
    canvas.save(filePath) catch {
        std.debug.print("{s}\n", .{"Couldn't save the canvas on your file system."});
    };

    return 0;
}
```

## Documentation

Find the full documentation on (https://zig-canvas.learn-zig.com)[https://zig-canvas.learn-zig.com]