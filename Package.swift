// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "SlackKit",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(name: "SlackKit", targets: ["SlackKit"]),
        .library(name: "SKClient", targets: ["SKClient"]),
        .library(name: "SKCore", targets: ["SKCore"]),
        .library(name: "SKRTMAPI", targets: ["SKRTMAPI"]),
        .library(name: "SKServer", targets: ["SKServer"]),
        .library(name: "SKWebAPI", targets: ["SKWebAPI"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor", from: Version(4, 76, 0)),
        .package(url: "https://github.com/vapor/websocket-kit", from: Version(2, 5, 0)),
        .package(url: "https://github.com/daltoniam/Starscream", from: Version(4, 0, 4)),
    ],
    targets: [
        .target(name: "SlackKit",
                dependencies: ["SKCore", "SKClient", "SKRTMAPI", "SKServer"],
                path: "SlackKit/Sources"),
        .target(name: "SKClient",
                dependencies: ["SKCore"],
                path: "SKClient/Sources"),
        .target(name: "SKCore",
                path: "SKCore/Sources"),
        .target(name: "SKRTMAPI",
                dependencies: [
                    "SKCore",
                    "SKWebAPI",
                    .product(name: "Starscream", package: "Starscream", condition: .when(platforms: [.macOS, .iOS, .tvOS])),
                    .product(name: "WebSocketKit", package: "websocket-kit", condition: .when(platforms: [.macOS, .linux])),
                ],
                path: "SKRTMAPI/Sources"),
        .target(name: "SKServer",
                dependencies: [
                    "SKCore",
                    "SKWebAPI",
                    .product(name: "Vapor", package: "vapor"),
                ],
                path: "SKServer/Sources"),
        .target(name: "SKWebAPI",
                dependencies: ["SKCore"],
                path: "SKWebAPI/Sources"),
        .testTarget(name: "SlackKitTests",
                dependencies: ["SlackKit", "SKCore", "SKClient", "SKRTMAPI", "SKServer"],
                path: "SlackKitTests",
                exclude: [
                    "Supporting Files"
                ],
                resources: [
                    .copy("Resources")
                ])
    ],
    swiftLanguageVersions: [.v5]
)
