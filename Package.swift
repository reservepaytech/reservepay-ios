// swift-tools-version: 5.9
import PackageDescription

// binaryURL + binaryChecksum must match the tagged GitHub Release asset (zip name and bytes).
let binaryURL =
    "https://github.com/reservepaytech/reservepay-ios/releases/download/1.0.0/ReservepaySDK.xcframework.zip"
let binaryChecksum =
    "ff76991c1f9a6fb6e3ad9adf0f1ab0bd1725cb7e108eb7b5912a2ece125ae632"

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
