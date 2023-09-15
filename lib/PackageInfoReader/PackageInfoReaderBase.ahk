class PackageInfoReaderBase {
    _config := ""

    __New(container, config) {
        this._config = config
    }

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
    *      "location": "https://github.com/my/package.git
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
    ReadPackageInfo(version, versionData) {

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

    }
}
