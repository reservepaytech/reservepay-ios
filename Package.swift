// swift-tools-version: 5.9
import PackageDescription

// binaryURL + binaryChecksum must match the tagged GitHub Release asset (zip name and bytes).
let binaryURL =
    "https://github.com/reservepaytech/reservepay-ios/releases/download/1.0.0/ReservepaySDK.xcframework.zip"
let binaryChecksum =
    "2a6a45c7e2582d71cfcf1b368de6e7882ceced910b4b71398fc33abfb5ed9164"

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
