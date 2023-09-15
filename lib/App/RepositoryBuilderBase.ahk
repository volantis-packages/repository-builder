class RepositoryBuilderBase extends AppBase {
    GetParameterDefinitions(config) {
        parameters := super.GetParameterDefinitions(config)
        parameters["config_path"] := "@@{app_dir}\volantis-builder.json"
        parameters["config.build_dir"] := "@@{app_dir}\Build"
        parameters["config.package_info_writer_type"] := "json"
        parameters["config.cleanup_build_artifacts"] := false
        parameters["config.open_build_dir"] := false
        parameters["config.open_dist_dir"] := true
        return parameters
    }

    GetServiceDefinitions(config) {
        services := super.GetServiceDefinitions(config)

        services["package_info_reader.github"] := Map(
            "class", "GitHubPackageInfoReader",
            "arguments", ["@config.app"]
        )

        services["package_info_writer.json"] := Map(
            "class", "JsonPackageInfoWriter",
            "arguments", ["@config.app"]
        )

        services["repository_info_builder"] := Map(
            "class", "SimpleRepositoryInfoBuilder",
            "arguments", ["@{}", "@config.app"]
        )

        return services
    }

    RunApp(config) {
        super.RunApp(config)
        this.Service["repository_info_builder"].BuildRepository()
        this.ExitApp()
    }

    ExitApp() {
        this.CleanupBuild()
        super.ExitApp()
    }

    CleanupBuild() {
        if (this.Config["cleanup_build_artifacts"]) {
            if (DirExist(this.Config["build_dir"])) {
                DirDelete(this.Config["build_dir"], true)
            }
        }
    }
}
