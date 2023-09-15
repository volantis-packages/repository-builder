class GitHubPackageInfoReader extends PackageInfoReaderBase {
    /**
     * Reads package information for all available versions of a package at the given location.
     *
     * What values are supported for the packageLocation depends on the specific implementation.
     *
     * The return value should be like:
     *
     * {
    *    @volantis.json,
    *    "version": "dev-main",
    *    "source": {
    *      "type": "git",
    *      "location": "https://github.com/my/package.git,
    *      "ref": "main"
    *    },
    *    "dist": {
    *      "type": "zip",
    *      "location": "https://github.com/my/package/releases/something.zip"
    *    }
    *  }
     *
     * where @volantis.json is the contents of the volantis.json file from that package version, which is merged with
     * the information that follows it.
     *
     * Note that source and dist are optional, but at least one of them must be present, and both is ideal. Typically,
     * you want to provide at least a source for dev versions, and at least a dist for release versions.
     */
    ReadPackageInfo(packageLocation, versionInfo) {
        shaRef := versionInfo["data"]["object"]["sha"]
        packageInfo := this.GetVolantisJsonObj(packageLocation, versionInfo["data"]["object"]["sha"])
        isTag := (versionInfo["data"]["object"]["type"] == "tag")

        ; https://api.github.com/repos/git/git/contents/README.md?ref=274b9cc25322d9ee79aa8e6d4e86f0ffe5ced925

        packageInfo["version"] := versionInfo["version"]
        packageInfo["source"] := Map(
            "type", "git",
            "location", "https://github.com/" . packageLocation . ".git",
            "ref", versionInfo["data"]["ref"]
        )

        ; @todo Prefer release assets over zipballs when available
        packageInfo["dist"] := Map(
            "type", "zip",
            "location", "https://api.github.com/repos/" . packageLocation . "/zipball/" . shaRef
        )

        return packageInfo
    }

    GetVolantisJsonObj(packageLocation, shaRef) {
        volantisJsonReq := WinHttpReq("https://api.github.com/repos/" . packageLocation . "/contents/volantis.json?ref=" . shaRef)
        responseData := volantisJsonReq.Get()

        jsonObj := ""

        if (volantisJsonReq.GetStatusCode() == 200) {
            fileJson := JsonData().FromString(responseData)

            if (fileJson.Has("download_url")) {
                responseData := WinHttpReq(fileJson["download_url"]).Get()

                if (responseData) {
                    jsonObj := JsonData().FromString(responseData)
                }
            }
        }

        return jsonObj
    }

    /**
     * Return a list of available versions for the given package location in the format:
     *
     * [
     *   {
     *     "version": "1.0",
     *     "data": {...} (context-dependent data)
     *   }
     * ]
     */
    DetectVersions(packageLocation) {
        versions := []
        this.AddGitHubVersions(versions, packageLocation, "tags")
        this.AddGitHubVersions(versions, packageLocation, "heads")

        return versions
    }

    AddGitHubVersions(versions, packageLocation, refType := "tags") {
        request := WinHttpReq("https://api.github.com/repos/" . packageLocation . "/git/refs/heads")
        responseData := request.Get()

        if (responseData) {
            responseObj := JsonData().FromString(responseData)

            for , versionInfo in responseObj {
                versionRef := SubStr(versionInfo["ref"], StrLen("refs/" . refType . "/") + 1)

                if (refType == "tag" && SubStr(versionRef, 1, 1) == "v") {
                    versionRef := SubStr(versionRef, 2)
                }

                versions.Push(Map(
                    "version", versionRef,
                    "data", versionInfo
                ))
            }
        }
    }
}
