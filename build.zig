const std = @import("std");

pub fn build(b: *std.Build) void {
    const decoder_module = b.addModule("decoder", .{ .root_source_file = b.path("src/decoder.zig") });
    decoder_module.addCSourceFile(.{ .file = b.path("src/minimp3_impl.c") });
    decoder_module.addIncludePath(b.path("src"));

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const example = b.addExecutable(.{
        .name = "mp3decode",
        .root_source_file = b.path("example/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    example.root_module.addImport("decoder", decoder_module);
    b.installArtifact(example);

    const run_cmd = b.addRunArtifact(example);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
