// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "CLProcessor",
    platforms: [.iOS(.v13), .tvOS(.v13)],
    products: [
        .library(
            name: "CLProcessor",
            targets: ["CLProcessor", "Lab"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "CLProcessor",
                      dependencies: ["Lab"],
                      path: "Sources/Processor"),
        .target(name: "Lab",
                dependencies: [],
                path: "Sources/cmsObjC",
                resources: [.copy("cms/sRGB_ICC_v4_Appearance.icc"),
                            .copy("cms/sRGB_v4_ICC_preference.icc")],
                publicHeadersPath: "include")
    ]
)

