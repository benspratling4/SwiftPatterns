// swift-tools-version:5.0
import PackageDescription
let package = Package(
	name: "SwiftPatterns",
	products: [
		.library(name: "SwiftPatterns", targets: ["SwiftPatterns"]),
	],
	dependencies:[],
	targets: [
		.target(name: "SwiftPatterns", dependencies: []),
		.testTarget(name: "SwiftPatternsTests", dependencies: ["SwiftPatterns"]),
		],
	swiftLanguageVersions:[.v5]
)
