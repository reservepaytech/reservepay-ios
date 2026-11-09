// swift-tools-version: 5.9
import PackageDescription

// binaryURL + binaryChecksum must match the tagged GitHub Release asset (zip name and bytes).
let binaryURL =
    "https://github.com/reservepaytech/reservepay-ios/releases/download/1.0.2/ReservepaySDK.xcframework.zip"
let binaryChecksum =
    "ae59ece618a53d149f3f8fdb2ff54d9c785bf4ec825be5ef7deb400671efffc5"

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
