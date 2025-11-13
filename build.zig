const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const decoder_module = b.addModule("decoder", .{ .root_source_file = b.path("src/decoder.zig"), .target = target, .optimize = optimize });
    decoder_module.addCSourceFile(.{ .file = b.path("src/minimp3_impl.c") });
    decoder_module.addIncludePath(b.path("src"));

    const libminimp3 = b.addLibrary(.{ .name = "minimp3", .linkage = .static, .root_module = decoder_module });

    const exe = b.addExecutable(.{
        .name = "mp3decode",
        .root_module = b.createModule(.{
            .root_source_file = b.path("example/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    exe.root_module.addImport("decoder", decoder_module);
    exe.linkLibrary(libminimp3);
    b.installArtifact(libminimp3);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_unit_tests = b.addTest(.{
        .root_module = decoder_module,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
