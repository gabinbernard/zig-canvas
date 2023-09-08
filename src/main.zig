const std = @import("std");
const createCanvas = @import("./lib.zig").createCanvas;
const milliTimestamp = @import("std").time.milliTimestamp;

pub fn shader(x: u16, y: u16, _: u32) u32 {
    var xCoord: f32 = @as(f32, @floatFromInt(x)) / 1000 - 1;
    var yCoord: f32 = @as(f32, @floatFromInt(y)) / 1000 - 1;

    var atan = std.math.atan2(f32, yCoord, xCoord);
    if (std.math.isNan(atan)) atan = 0;

    var radius: f32 = @sqrt(xCoord * xCoord + yCoord * yCoord);
    if (std.math.isNan(radius)) radius = 0;
    var angle: f32 = @cos(radius * 10.0) + @cos(@cos(radius) * 10 + 12 * atan);

    const v1: f32 = if (angle > 0) 0.35 else 1;
    var r: u8 = @as(u8, @intFromFloat((v1 - v1 * @cos(atan + 0.0)) * 127.9)) +| 60 -| @as(u8, @intFromFloat(radius * 80));
    var g: u8 = @as(u8, @intFromFloat((v1 - v1 * @cos(atan + 2.0)) * 127.9)) +| 60 -| @as(u8, @intFromFloat(radius * 80));
    var b: u8 = @as(u8, @intFromFloat((v1 - v1 * @cos(atan + 4.0)) * 127.9)) +| 60 -| @as(u8, @intFromFloat(radius * 80));

    return @as(u32, r) << 24 | @as(u32, g) << 16 | @as(u32, b) << 8 | 0xff;
}

pub fn main() !u8 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const width = 2000;
    const height = 2000;
    var canvas = try createCanvas(width, height, .rgba, allocator);
    canvas.fillStyle = 0x22ddeeff;
    const ts = milliTimestamp();
    canvas.applyPixelShader(shader);
    for (0..5) |i| {
        const filePath: []const u8 = try std.fmt.allocPrint(allocator, "/mnt/c/Users/Utilisateur/Desktop/img/file-{}.bmp", .{i});
        canvas.save(filePath) catch {
            std.debug.print("{s}\n", .{"File does not exist"});
        };
    }
    std.debug.print("{}\n", .{milliTimestamp() - ts});

    return 0;
}
