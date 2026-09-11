// swift-tools-version: 5.9
import PackageDescription

// binaryURL + binaryChecksum must match the tagged GitHub Release asset (zip name and bytes).
let binaryURL =
    "https://github.com/reservepaytech/reservepay-ios/releases/download/1.0.1/ReservepaySDK.xcframework.zip"
let binaryChecksum =
    "6e8ebb639a7c4310ebb19b9c3c0432509ba2e656a71ac17bdb65eca1ddd15838"

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
