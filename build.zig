const std = @import("std");

pub fn build(b: *std.Build) void {
    // const target = b.standardTargetOptions(.{});

    // const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = b.path("src/kernel.zig"),
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .riscv32,
            .os_tag = .freestanding,
            .abi = .none,
        }),
        .optimize = .ReleaseSmall,
        // .optimize = .ReleaseSafe,
        .strip = false,
    });

    exe.entry = .disabled;

    exe.setLinkerScript(b.path("src/kernel.ld"));

    b.installArtifact(exe);

    const run_cmd = b.addSystemCommand(&.{"qemu-system-riscv32"});
    run_cmd.addArgs(&.{
        "-machine", "virt",
        "-bios",    "default",
        "-serial",  "mon:stdio",
        "--no-reboot", // "-nographics",
        "-kernel",
    });

    run_cmd.addArtifactArg(exe);

    const run_step = b.step("run", "Run the QEMU");
    run_step.dependOn(&run_cmd.step);
}
