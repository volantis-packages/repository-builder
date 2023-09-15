class JsonPackageInfoWriter extends PackageInfoWriterBase {
    /**
     * Writes package information to the specified destination.
     *
     * What kind of destination is used and how the package information is written
     * is unspecified and depends on the implementation.
     *
     * The ability to read the information back is not required in this library,
     * but custom implementations may require a custom adapter for the volantis
     * package manager to read the library.
     *
     * The most common destination type is simply a JSON file containing an
     * exact representation of the provided data.
     */
    WritePackageInfo(packageName, packageInformation, destination) {
        json := Map("packages", Map(
            packageName, packageInformation
        ))

        JsonData(json).ToFile(destination, true, 4)
    }
}
