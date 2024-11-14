pub const ProgramCounter = struct {
    addr: u16,

    pub fn init() ProgramCounter {
        return .{ .addr = 0x200 };
    }

    pub fn get(self: *const ProgramCounter) u16 {
        return self.addr;
    }

    pub fn increment(self: *ProgramCounter) void {
        self.addr += 2;
    }

    pub fn jump(self: *ProgramCounter, addr: u16) void {
        self.addr = addr;
    }
};
