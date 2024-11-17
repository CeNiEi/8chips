const std = @import("std");
const Font = @import("fonts.zig").Font;
const Error = @import("error.zig").Error;

pub const Memory = struct {
    const MEM_SIZE: usize = 4096;
    mem: [MEM_SIZE]u8,

    fn initZeroed() Memory {
        const mem = [_]u8{0} ** MEM_SIZE;

        return .{ .mem = mem };
    }

    pub fn loadFont(self: *Memory) void {
        for (Font.SPRITES, 0x50..) |value, n| {
            self.mem[n] = value;
        }
    }

    pub fn init(path: []const u8) !Memory {
        var memory = Memory.initZeroed();
        memory.loadFont();

        var file = try std.fs.openFileAbsolute(path, .{ .mode = .read_only });
        defer file.close();

        _ = try file.read(memory.mem[0x200..]);

        return memory;
    }

    pub fn load(self: *const Memory, addr: u16) !u8 {
        if (addr < 0 and addr >= MEM_SIZE) {
            std.log.err("\n[OutOfBounds]: Tried to access invalid address {s}\n", .{addr});
            return Error.OutOfBounds;
        }

        return self.mem[addr];
    }

    pub fn store(self: *Memory, addr: u16, value: u8) void {
        self.mem[addr] = value;
    }

    pub fn getNBytesAt(self: *const Memory, at: u16, n: u16) ![]const u8 {
        if (at < 0 and at + n >= MEM_SIZE) {
            std.log.err("\n[OutOfBounds]: Tried to access invalid address {s}\n", .{ at, n });
            return Error.OutOfBounds;
        }

        return self.mem[at .. at + n];
    }
};
