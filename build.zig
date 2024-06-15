const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const linkage = b.option(std.builtin.LinkMode, "linkage", "Specify static or dynamic linkage") orelse .dynamic;
    const upstream = b.dependency("rmw", .{});
    var lib = std.Build.Step.Compile.create(b, .{
        .root_module = .{
            .target = target,
            .optimize = optimize,
        },
        .name = "rmw",
        .kind = .lib,
        .linkage = linkage,
    });

    lib.linkLibC();
    lib.addIncludePath(upstream.path("rmw/include"));

    const rcutils_dep = b.dependency("rcutils", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });

    lib.linkLibrary(rcutils_dep.artifact("rcutils"));

    const rosidl_dep = b.dependency("rosidl", .{
        .target = target,
        .optimize = optimize,
        .linkage = linkage,
    });

    lib.linkLibrary(rosidl_dep.artifact("rosidl_runtime_c"));

    lib.addCSourceFiles(.{
        .root = upstream.path("rmw"),
        .files = &.{
            "src/allocators.c",
            "src/convert_rcutils_ret_to_rmw_ret.c",
            "src/discovery_options.c",
            "src/event.c",
            "src/init.c",
            "src/init_options.c",
            "src/message_sequence.c",
            "src/names_and_types.c",
            "src/network_flow_endpoint_array.c",
            "src/network_flow_endpoint.c",
            "src/publisher_options.c",
            "src/qos_string_conversions.c",
            "src/sanity_checks.c",
            "src/security_options.c",
            "src/subscription_content_filter_options.c",
            "src/subscription_options.c",
            "src/time.c",
            "src/topic_endpoint_info_array.c",
            "src/topic_endpoint_info.c",
            "src/types.c",
            "src/validate_full_topic_name.c",
            "src/validate_namespace.c",
            "src/validate_node_name.c",
        },
    });

    lib.installHeadersDirectory(
        upstream.path("rmw/include"),
        "",
        .{ .include_extensions = &.{ ".h", ".hpp" } },
    );
    b.installArtifact(lib);
}
