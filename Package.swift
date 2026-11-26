// swift-tools-version: 5.9
import PackageDescription

// binaryURL + binaryChecksum must match the tagged GitHub Release asset (zip name and bytes).
let binaryURL =
    "https://github.com/reservepaytech/reservepay-ios/releases/download/1.1.0/ReservepaySDK.xcframework.zip"
let binaryChecksum =
    "1c076ae9f3506924b03d31b344293b4b43e94c508b6934a35654c2c5ae872f7f"

let package = Package(
    name: "ReservepaySDK",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "ReservepaySDK", targets: ["ReservepaySDKBinary"]),
        .library(name: "ReservepaySwiftUI", targets: ["ReservepaySwiftUI"]),
    ],
    targets: [
        .binaryTarget(
            name: "ReservepaySDKBinary",
            url: binaryURL,
            checksum: binaryChecksum
        ),
        .target(
            name: "ReservepaySwiftUI",
            dependencies: ["ReservepaySDKBinary"],
            path: "Sources/ReservepaySwiftUI"
        ),
    ]
)
