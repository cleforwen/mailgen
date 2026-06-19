// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MailGen",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "MailGen",
            path: "Sources/MailGen"
        )
    ]
)
