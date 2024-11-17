const std = @import("std");
const Error = @import("error.zig").Error;

pub const Instruction = union(enum) {
    inst_00E0,
    inst_00EE,
    inst_1NNN: u16,
    inst_2NNN: u16,
    inst_3XNN: struct {
        reg: u8,
        val: u8,
    },
    inst_4XNN: struct {
        reg: u8,
        val: u8,
    },
    inst_5XY0: struct {
        x_reg: u8,
        y_reg: u8,
    },
    inst_6XNN: struct {
        reg: u8,
        val: u8,
    },
    inst_7XNN: struct {
        reg: u8,
        val: u8,
    },
    inst_8XY0: struct {
        x_reg: u8,
        y_reg: u8,
    },
    inst_8XY1: struct {
        x_reg: u8,
        y_reg: u8,
    },
    inst_8XY2: struct {
        x_reg: u8,
        y_reg: u8,
    },
    inst_8XY3: struct {
        x_reg: u8,
        y_reg: u8,
    },
    inst_8XY4: struct {
        x_reg: u8,
        y_reg: u8,
    },
    inst_8XY5: struct {
        x_reg: u8,
        y_reg: u8,
    },
    inst_8XY6: struct {
        x_reg: u8,
        y_reg: u8,
    },
    inst_8XY7: struct {
        x_reg: u8,
        y_reg: u8,
    },
    inst_8XYE: struct {
        x_reg: u8,
        y_reg: u8,
    },
    inst_9XY0: struct {
        x_reg: u8,
        y_reg: u8,
    },
    inst_ANNN: u16,
    inst_BNNN: u16,
    inst_DXYN: struct {
        x_reg: u8,
        y_reg: u8,
        height: u8,
    },
    inst_EX9E: u8,
    inst_EXA1: u8,
    inst_FX0A: u8,
    inst_FX07: u8,
    inst_FX15: u8,
    inst_FX18: u8,
    inst_FX1E: u8,
    inst_FX33: u8,
    inst_FX55: u8,
    inst_FX65: u8,

    pub fn init(raw_inst: u16) !Instruction {
        const raw_inst_le = @byteSwap(raw_inst);

        const first_nibble = (raw_inst_le & 0xF000) >> 12;

        return switch (first_nibble) {
            0x0 => {
                std.debug.assert((raw_inst_le & 0x0FF0) >> 4 == 0x0e);
                const fourth_nibble = (raw_inst_le & 0x000F);

                switch (fourth_nibble) {
                    0x0 => {
                        return Instruction.inst_00E0;
                    },
                    0xe => {
                        return Instruction.inst_00EE;
                    },
                    else => {
                        std.log.err("\n[InvalidInstruction]: 0x{x}\n", .{raw_inst_le});
                        return Error.InvalidInstruction;
                    },
                }
            },
            0x1 => {
                const addr = raw_inst_le & 0x0FFF;
                return Instruction{ .inst_1NNN = addr };
            },
            0x2 => {
                const addr = raw_inst_le & 0x0FFF;
                return Instruction{ .inst_2NNN = addr };
            },
            0x3 => {
                const reg: u8 = @intCast((raw_inst_le & 0x0F00) >> 8);
                const val: u8 = @intCast((raw_inst_le & 0x00FF));

                return Instruction{ .inst_3XNN = .{
                    .reg = reg,
                    .val = val,
                } };
            },
            0x4 => {
                const reg: u8 = @intCast((raw_inst_le & 0x0F00) >> 8);
                const val: u8 = @intCast((raw_inst_le & 0x00FF));

                return Instruction{ .inst_4XNN = .{
                    .reg = reg,
                    .val = val,
                } };
            },
            0x5 => {
                const x_reg: u8 = @intCast((raw_inst_le & 0x0F00) >> 8);
                const y_reg: u8 = @intCast((raw_inst_le & 0x00F0) >> 4);

                std.debug.assert((raw_inst_le & 0x000F) == 0x0);

                return Instruction{ .inst_5XY0 = .{
                    .x_reg = x_reg,
                    .y_reg = y_reg,
                } };
            },
            0x6 => {
                const reg: u8 = @intCast((raw_inst_le & 0x0F00) >> 8);
                const val: u8 = @intCast((raw_inst_le & 0x00FF));

                return Instruction{ .inst_6XNN = .{
                    .reg = reg,
                    .val = val,
                } };
            },
            0x7 => {
                const reg: u8 = @intCast((raw_inst_le & 0x0F00) >> 8);
                const val: u8 = @intCast((raw_inst_le & 0x00FF));

                return Instruction{ .inst_7XNN = .{
                    .reg = reg,
                    .val = val,
                } };
            },
            0x8 => {
                const x_reg: u8 = @intCast((raw_inst_le & 0x0F00) >> 8);
                const y_reg: u8 = @intCast((raw_inst_le & 0x00F0) >> 4);
                const fourth_nibble = (raw_inst_le & 0x000F);

                switch (fourth_nibble) {
                    0x0 => {
                        return Instruction{ .inst_8XY0 = .{
                            .x_reg = x_reg,
                            .y_reg = y_reg,
                        } };
                    },
                    0x1 => {
                        return Instruction{ .inst_8XY1 = .{
                            .x_reg = x_reg,
                            .y_reg = y_reg,
                        } };
                    },
                    0x2 => {
                        return Instruction{ .inst_8XY2 = .{
                            .x_reg = x_reg,
                            .y_reg = y_reg,
                        } };
                    },
                    0x3 => {
                        return Instruction{ .inst_8XY3 = .{
                            .x_reg = x_reg,
                            .y_reg = y_reg,
                        } };
                    },
                    0x4 => {
                        return Instruction{ .inst_8XY4 = .{
                            .x_reg = x_reg,
                            .y_reg = y_reg,
                        } };
                    },
                    0x5 => {
                        return Instruction{ .inst_8XY5 = .{
                            .x_reg = x_reg,
                            .y_reg = y_reg,
                        } };
                    },
                    0x6 => {
                        return Instruction{ .inst_8XY6 = .{
                            .x_reg = x_reg,
                            .y_reg = y_reg,
                        } };
                    },
                    0x7 => {
                        return Instruction{ .inst_8XY7 = .{
                            .x_reg = x_reg,
                            .y_reg = y_reg,
                        } };
                    },
                    0xe => {
                        return Instruction{ .inst_8XYE = .{
                            .x_reg = x_reg,
                            .y_reg = y_reg,
                        } };
                    },

                    else => {
                        std.log.err("\n[InvalidInstruction]: 0x{x}\n", .{raw_inst_le});
                        return Error.InvalidInstruction;
                    },
                }
            },
            0x9 => {
                const x_reg: u8 = @intCast((raw_inst_le & 0x0F00) >> 8);
                const y_reg: u8 = @intCast((raw_inst_le & 0x00F0) >> 4);

                std.debug.assert((raw_inst_le & 0x000F) == 0x0);

                return Instruction{ .inst_9XY0 = .{
                    .x_reg = x_reg,
                    .y_reg = y_reg,
                } };
            },
            0xA => {
                const addr = raw_inst_le & 0x0FFF;
                return Instruction{ .inst_ANNN = addr };
            },
            0xB => {
                const addr = raw_inst_le & 0x0FFF;
                return Instruction{ .inst_BNNN = addr };
            },
            0xD => {
                const x_reg: u8 = @intCast((raw_inst_le & 0x0F00) >> 8);
                const y_reg: u8 = @intCast((raw_inst_le & 0x00F0) >> 4);
                const height: u8 = @intCast((raw_inst_le & 0x000F));

                return Instruction{ .inst_DXYN = .{
                    .x_reg = x_reg,
                    .y_reg = y_reg,
                    .height = height,
                } };
            },
            0xE => {
                const reg: u8 = @intCast((raw_inst_le & 0x0F00) >> 8);
                const second_byte = (raw_inst_le & 0x00FF);

                switch (second_byte) {
                    0x9E => {
                        return Instruction{ .inst_EX9E = reg };
                    },
                    0xA1 => {
                        return Instruction{ .inst_EXA1 = reg };
                    },

                    else => {
                        std.log.err("\n[InvalidInstruction]: 0x{x}\n", .{raw_inst_le});
                        return Error.InvalidInstruction;
                    },
                }
            },
            0xF => {
                const reg: u8 = @intCast((raw_inst_le & 0x0F00) >> 8);

                const second_byte = (raw_inst_le & 0x00FF);

                switch (second_byte) {
                    0x07 => {
                        return Instruction{ .inst_FX07 = reg };
                    },
                    0x0a => {
                        return Instruction{ .inst_FX0A = reg };
                    },
                    0x15 => {
                        return Instruction{ .inst_FX15 = reg };
                    },
                    0x18 => {
                        return Instruction{ .inst_FX18 = reg };
                    },
                    0x1e => {
                        return Instruction{ .inst_FX1E = reg };
                    },
                    0x33 => {
                        return Instruction{ .inst_FX33 = reg };
                    },
                    0x55 => {
                        return Instruction{ .inst_FX55 = reg };
                    },
                    0x65 => {
                        return Instruction{ .inst_FX65 = reg };
                    },
                    else => {
                        std.log.err("\n[InvalidInstruction]: 0x{x}\n", .{raw_inst_le});
                        return Error.InvalidInstruction;
                    },
                }
            },
            else => {
                std.log.err("\n[InvalidInstruction]: 0x{x}\n", .{raw_inst_le});
                return Error.InvalidInstruction;
            },
        };
    }
};
