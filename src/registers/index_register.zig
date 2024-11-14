pub const IndexRegister = struct {
    addr: u16,

    pub fn init() IndexRegister {
        return .{ .addr = 0x0 };
    }

    pub fn get(self: *const IndexRegister) u16 {
        return self.addr;
    }

    pub fn set(self: *IndexRegister, val: u16) void {
        self.addr = val;
    }

    pub fn increment(self: *IndexRegister) void {
        self.addr += 1;
    }
};
