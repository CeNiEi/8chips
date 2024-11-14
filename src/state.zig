const std = @import("std");
const utils = @import("utils.zig");

const Error = @import("error.zig").Error;
const Display = @import("display.zig").Display;
const Memory = @import("memory.zig").Memory;
const Instruction = @import("instructions.zig").Instruction;
const ProgramCounter = @import("registers/program_counter.zig").ProgramCounter;
const Stack = @import("stack.zig").Stack;
const Registers = @import("registers/general.zig").Registers;
const IndexRegister = @import("registers//index_register.zig").IndexRegister;

pub const Ambiguity = enum {
    old,
    new,
};

pub const State = struct {
    display: Display,
    memory: Memory,
    stack: Stack,
    program_counter: ProgramCounter,
    index_register: IndexRegister,
    registers: Registers,

    config: struct {
        ambiguity_8xy6_8xye: Ambiguity,
        ambiguity_fx55_fx65: Ambiguity,
    },

    pub fn init(path: []const u8) !State {
        try utils.initSDL();

        const display = try Display.init();
        const memory = try Memory.init(path);
        const program_counter = ProgramCounter.init();
        const stack = try Stack.init();
        const registers = Registers.init();
        const index_register = IndexRegister.init();

        return .{
            .display = display,
            .memory = memory,
            .program_counter = program_counter,
            .stack = stack,
            .registers = registers,
            .index_register = index_register,
            .config = .{
                .ambiguity_8xy6_8xye = Ambiguity.new,
                .ambiguity_fx55_fx65 = Ambiguity.new,
            },
        };
    }

    pub fn deinit(self: *const State) void {
        self.display.deinit();
        utils.deinitSDL();
    }

    pub fn fetch(self: *const State) !Instruction {
        const mem_addr = self.program_counter.get();
        const raw_instruction = try self.memory.getNBytesAt(mem_addr, 2);

        return Instruction.init(std.mem.bytesToValue(u16, raw_instruction));
    }

    pub fn execute(self: *State, inst: Instruction) !void {
        switch (inst) {
            Instruction.inst_00E0 => {
                try self.display.clear();
                try self.display.flush();
                self.program_counter.increment();
            },
            Instruction.inst_00EE => {
                const stack_top = self.stack.pop() orelse return Error.StackEmpty;
                self.program_counter.jump(stack_top);
                self.program_counter.increment();
            },
            Instruction.inst_1NNN => |addr| {
                self.program_counter.jump(addr);
            },
            Instruction.inst_2NNN => |addr| {
                try self.stack.push(self.program_counter.get());
                self.program_counter.jump(addr);
            },
            Instruction.inst_3XNN => |payload| {
                const reg_val = self.registers.getReg(payload.reg);

                if (reg_val == payload.val) {
                    self.program_counter.increment();
                }

                self.program_counter.increment();
            },
            Instruction.inst_4XNN => |payload| {
                const reg_val = self.registers.getReg(payload.reg);

                if (reg_val != payload.val) {
                    self.program_counter.increment();
                }

                self.program_counter.increment();
            },
            Instruction.inst_5XY0 => |payload| {
                const x_reg_val = self.registers.getReg(payload.x_reg);
                const y_reg_val = self.registers.getReg(payload.y_reg);

                if (x_reg_val == y_reg_val) {
                    self.program_counter.increment();
                }

                self.program_counter.increment();
            },
            Instruction.inst_6XNN => |payload| {
                self.registers.setReg(payload.reg, payload.val);
                self.program_counter.increment();
            },
            Instruction.inst_7XNN => |payload| {
                const res = self.registers.getReg(payload.reg) +% payload.val;
                self.registers.setReg(payload.reg, res);
                self.program_counter.increment();
            },
            Instruction.inst_8XY0 => |payload| {
                const y_reg_val = self.registers.getReg(payload.y_reg);
                self.registers.setReg(payload.x_reg, y_reg_val);
                self.program_counter.increment();
            },
            Instruction.inst_8XY1 => |payload| {
                const x_reg_val = self.registers.getReg(payload.x_reg);
                const y_reg_val = self.registers.getReg(payload.y_reg);

                self.registers.setReg(payload.x_reg, x_reg_val | y_reg_val);
                self.program_counter.increment();
            },
            Instruction.inst_8XY2 => |payload| {
                const x_reg_val = self.registers.getReg(payload.x_reg);
                const y_reg_val = self.registers.getReg(payload.y_reg);

                self.registers.setReg(payload.x_reg, x_reg_val & y_reg_val);
                self.program_counter.increment();
            },
            Instruction.inst_8XY3 => |payload| {
                const x_reg_val = self.registers.getReg(payload.x_reg);
                const y_reg_val = self.registers.getReg(payload.y_reg);

                self.registers.setReg(payload.x_reg, x_reg_val ^ y_reg_val);
                self.program_counter.increment();
            },
            Instruction.inst_8XY4 => |payload| {
                const x_reg_val = self.registers.getReg(payload.x_reg);
                const y_reg_val = self.registers.getReg(payload.y_reg);

                const res = @addWithOverflow(x_reg_val, y_reg_val);
                self.registers.setReg(payload.x_reg, res[0]);
                self.registers.setReg(0xF, res[1]);

                self.program_counter.increment();
            },
            Instruction.inst_8XY5 => |payload| {
                const x_reg_val = self.registers.getReg(payload.x_reg);
                const y_reg_val = self.registers.getReg(payload.y_reg);

                const res = @subWithOverflow(x_reg_val, y_reg_val);
                self.registers.setReg(payload.x_reg, res[0]);
                self.registers.setReg(0xF, res[1] ^ 1);

                self.program_counter.increment();
            },
            Instruction.inst_8XY6 => |payload| {
                if (self.config.ambiguity_8xy6_8xye == Ambiguity.old) {
                    self.registers.setReg(payload.x_reg, self.registers.getReg(payload.y_reg));
                }

                const x_reg_val = self.registers.getReg(payload.x_reg);
                const res = x_reg_val >> 1;

                self.registers.setReg(payload.x_reg, res);
                self.registers.setReg(0xF, x_reg_val & 1);
                self.program_counter.increment();
            },
            Instruction.inst_8XY7 => |payload| {
                const x_reg_val = self.registers.getReg(payload.x_reg);
                const y_reg_val = self.registers.getReg(payload.y_reg);

                const res = @subWithOverflow(y_reg_val, x_reg_val);
                self.registers.setReg(payload.x_reg, res[0]);
                self.registers.setReg(0xF, res[1] ^ 1);

                self.program_counter.increment();
            },
            Instruction.inst_8XYE => |payload| {
                if (self.config.ambiguity_8xy6_8xye == Ambiguity.old) {
                    self.registers.setReg(payload.x_reg, self.registers.getReg(payload.y_reg));
                }

                const x_reg_val = self.registers.getReg(payload.x_reg);
                const res = x_reg_val << 1;

                self.registers.setReg(payload.x_reg, res);
                self.registers.setReg(0xF, (x_reg_val >> 7) & 1);
                self.program_counter.increment();
            },
            Instruction.inst_9XY0 => |payload| {
                const x_reg_val = self.registers.getReg(payload.x_reg);
                const y_reg_val = self.registers.getReg(payload.y_reg);

                if (x_reg_val != y_reg_val) {
                    self.program_counter.increment();
                }

                self.program_counter.increment();
            },
            Instruction.inst_ANNN => |addr| {
                self.index_register.set(addr);
                self.program_counter.increment();
            },
            Instruction.inst_DXYN => |payload| {
                var y = self.registers.getReg(payload.y_reg) % Display.DISPLAY_HEIGHT;

                self.registers.setReg(0x0F, 0);

                const index_reg_addr = self.index_register.get();

                for (0..payload.height) |n| {
                    var x = self.registers.getReg(payload.x_reg) % Display.DISPLAY_WIDTH;

                    const sprite_row = (try self.memory.getNBytesAt(index_reg_addr + @as(u16, @intCast(n)), 1))[0];

                    for (0..8) |i| {
                        const pixel = (sprite_row >> (7 - @as(u3, @intCast(i)))) & 1;

                        if (pixel == 1) {
                            if (self.display.getPixelStatus(x, y)) {
                                try self.display.unsetPixel(x, y);
                                self.registers.setReg(0x0F, 1);
                            } else {
                                try self.display.setPixel(x, y);
                                std.debug.assert(self.display.getPixelStatus(x, y));
                            }
                        }

                        x += 1;

                        if (x >= Display.DISPLAY_WIDTH) {
                            break;
                        }
                    }

                    y += 1;
                    if (y >= Display.DISPLAY_HEIGHT) {
                        break;
                    }
                }
                try self.display.flush();

                self.program_counter.increment();
            },
            Instruction.inst_FX1E => |reg| {
                const index_val = self.index_register.get();
                const reg_val = self.registers.getReg(reg);

                const res = @addWithOverflow(reg_val, index_val);
                self.index_register.set(res[0]);
                self.registers.setReg(0xF, res[1]);

                self.program_counter.increment();
            },
            Instruction.inst_FX33 => |reg| {
                const reg_val = self.registers.getReg(reg);

                self.memory.store(self.index_register.get(), reg_val / 100);
                self.memory.store(self.index_register.get() + 1, (reg_val / 10) % 10);
                self.memory.store(self.index_register.get() + 2, reg_val % 10);

                self.program_counter.increment();
            },
            Instruction.inst_FX55 => |reg| {
                for (0..(reg + 1)) |r| {
                    self.memory.store(self.index_register.get() + @as(u8, @intCast(r)), self.registers.getReg(r));
                    if (self.config.ambiguity_fx55_fx65 == Ambiguity.old) {
                        self.index_register.increment();
                    }
                }
                self.program_counter.increment();
            },
            Instruction.inst_FX65 => |reg| {
                for (0..(reg + 1)) |r| {
                    self.registers.setReg(r, try self.memory.load(self.index_register.get() + @as(u8, @intCast(r))));
                    if (self.config.ambiguity_fx55_fx65 == Ambiguity.old) {
                        self.index_register.increment();
                    }
                }
                self.program_counter.increment();
            },
        }
    }
};
