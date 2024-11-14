const std = @import("std");

pub const Stack = struct {
    const STACK_SIZE: usize = 16;

    st: std.BoundedArray(u16, STACK_SIZE * 2),

    pub fn init() !Stack {
        const st = try std.BoundedArray(u16, STACK_SIZE * 2).init(STACK_SIZE);
        return Stack{ .st = st };
    }

    pub fn push(self: *Stack, val: u16) !void {
        try self.st.append(val);
    }

    pub fn pop(self: *Stack) ?u16 {
        return self.st.popOrNull();
    }
};
