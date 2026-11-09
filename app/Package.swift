// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SkilldeckCore",
    platforms: [.macOS(.v15)],
    products: [.library(name: "SkilldeckCore", targets: ["SkilldeckCore"])],
    targets: [
        .target(name: "SkilldeckCore", path: "Sources/SkilldeckCore"),
        .testTarget(
            name: "SkilldeckCoreTests",
            dependencies: ["SkilldeckCore"],
            path: "Tests/SkilldeckCoreTests",
            resources: [.copy("Fixtures")]
        ),
    ],
    swiftLanguageModes: [.v5]
)
