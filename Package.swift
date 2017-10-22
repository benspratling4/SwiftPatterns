// swift-tools-version:4.0
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
	swiftLanguageVersions:[3,4]
)
