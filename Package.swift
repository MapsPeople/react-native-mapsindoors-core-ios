// swift-tools-version: 6.0

import PackageDescription

// Builds the React-free helpers in this folder so they can be unit tested with `swift test`. The rest
// of the folder imports React and is only ever compiled by the CocoaPods packages that ship it
// (react-native-maps-indoors-mapbox and react-native-maps-indoors-google-maps), whose podspecs exclude
// this manifest and `Tests/`.
let package = Package(
    name: "MapsIndoorsReactNativeCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    targets: [
        .target(
            name: "MainThread",
            path: "Sources/MainThread"
        ),
        .testTarget(
            name: "MainThreadTests",
            dependencies: ["MainThread"],
            path: "Tests/MainThreadTests"
        ),
    ]
)
