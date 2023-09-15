class RepositoryInfoBuilderBase {
    _container := ""
    _config := ""

    __New(container, config) {
        this._container = container
        this._config = config
    }

    BuildRepository() {
        packages := this._config.Has("packages") ? this._config["packages"] : []

        if (!packages) {
            packages := []
        }

        if (!List.IsArrayLike(packages)) {
            packages := [packages]
        }

        repositoryData := Map()

        writerType := this._config["package_info_writer_type"]

        if (!this._container.Has("package_info_writer." . writerType)) {
            throw DataException("Unknown package info writer type: " . writerType)
        }

        DirDelete(this._config["build_dir"], true)
        DirCreate(this._config["build_dir"])
        DirCreate(this._config["build_dir"] . "/packages")

        for , packageInfo in packages {
            if (Type(packageInfo) == "String") {
                packageInfo := Map("location", packageInfo)
            }

            if (!packageInfo.Has("location") || !packageInfo["location"]) {
                throw DataException("Invalid package info: no location specified")
            }

            this.AddRepositoryPackageData(repositoryData, packageInfo)
        }

        writer := this._container["package_info_writer." . writerType]

        for , packageInfo in repositoryData {
            if (!packageInfo.Has(1)) {
                continue
            }

            packageName := packageInfo[1]["name"]
            dest := this._config["build_dir"] . "/packages/" . packageName . ".json"
            writer.WritePackageInfo(packageName, packageInfo, dest)
        }

        if (this._config.Has("repository-info")) {
            repoFile := this._config["build_dir"] . "/volantis-repository.json"
            JsonData(this._config["repository-info"]).ToFile(repoFile, true, 4)
        }

        return true
    }

    AddRepositoryPackageData(repositoryData, packageInfo) {
        packageType := packageInfo.Has("type") ? packageInfo["type"] : "github"

        if (!this._container.Has("package_info_reader." . packageType)) {
            throw DataException("Unknown package info type: " . packageType)
        }

        packageInfoReader := this._container["package_info_reader." . packageType]
        versions := packageInfoReader.DetectVersions(packageInfo["location"])

        for , versionInfo in versions {
            versionPackageInfo := packageInfoReader.ReadPackageInfo(packageInfo["location"], versionInfo)

            if (versionPackageInfo) {
                packageName := versionPackageInfo["name"]

                if (!repositoryData.Has(packageName)) {
                    repositoryData[packageName] := []
                }

                repositoryData[packageName].Push(versionPackageInfo)
            }
        }
    }
}
