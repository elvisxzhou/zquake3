const std = @import("std");
const builtin = @import("builtin");
const Builder = std.build.Builder;
const path = std.fs.path;
const Target = std.zig.CrossTarget;

pub const Options = struct {
    artifact: *std.build.LibExeObjStep,
    prefix: []const u8 = ".",
    override_mode: ?std.builtin.Mode = null,
};

pub fn linkArtifact(b: *Builder, options: Options) void {
    const mode = options.override_mode orelse options.artifact.build_mode;
    const lib = getLibrary(b, mode, options.artifact.target);
    options.artifact.linkLibrary(lib);
}

pub fn getLibrary(
    b: *Builder,
    mode: std.builtin.Mode,
    target: Target,
) *std.build.LibExeObjStep {

    const lib_cflags = &[_][]const u8{
        "-DC_ONLY",
        "-fno-sanitize=undefined,memory,address,safe-stack"
    };

    const lib = b.addStaticLibrary("renderer", null);
    lib.setBuildMode(mode);
    lib.setTarget(target);

    lib.linkSystemLibrary("c");
    //lib.addIncludeDir("code/shared");
    //lib.addIncludeDir("deps/lua-5.1.5/src");
    const src_path = thisDir();
    for (generic_src_files) |src_file| {
        lib.addCSourceFile(b.fmt("{s}/{s}", .{src_path, src_file}), lib_cflags);
    }

    if (target.isWindows()) {
        for (windows_src_files) |src_file| {
            lib.addCSourceFile(src_file, lib_cflags);
        }
    } else if (target.isDarwin()) {
        for (darwin_src_files) |src_file| {
            lib.addCSourceFile(src_file, lib_cflags);
        }
    }
    return lib;
}

const generic_src_files = [_][]const u8{
    "tr_animation.c",
    "tr_backend.c",
    "tr_bsp.c",
    "tr_cmds.c",
    "tr_curve.c",
    "tr_flares.c",
    "tr_font.c",
    "tr_image.c",
    "tr_init.c",
    "tr_light.c",
    "tr_main.c",
    "tr_marks.c",
    "tr_mesh.c",
    "tr_model.c",
    "tr_noise.c",
    "tr_scene.c",
    "tr_shade.c",
    "tr_shade_calc.c",
    "tr_shader.c",
    "tr_shadows.c",
    "tr_sky.c",
    "tr_surface.c",
    "tr_world.c",
    "../win32/win_gamma.c",
    "../win32/win_glimp.c",
    "../win32/win_qgl.c",
  };

const linux_src_files = [_][]const u8{
};

const windows_src_files = [_][]const u8{
};

const darwin_src_files = [_][]const u8{
};

fn thisDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}