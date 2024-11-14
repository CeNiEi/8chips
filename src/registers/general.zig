pub const Registers = struct {
    const REG_COUNT: usize = 16;
    regs: [REG_COUNT]u8,

    pub fn init() Registers {
        const regs = [_]u8{0} ** REG_COUNT;
        return .{ .regs = regs };
    }

    pub fn setReg(self: *Registers, reg: usize, val: u8) void {
        self.regs[reg] = val;
    }

    pub fn getReg(self: *const Registers, reg: usize) u8 {
        return self.regs[reg];
    }
};
