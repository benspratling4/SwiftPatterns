// swift-tools-version:5.3
import PackageDescription
let package = Package(
	name: "SwiftPatterns",
	products: [
		.library(name: "SwiftPatterns", type:.dynamic, targets: ["SwiftPatterns"]),
	],
	dependencies:[],
	targets: [
		.target(name: "SwiftPatterns", dependencies: []),
		.testTarget(name: "SwiftPatternsTests", dependencies: ["SwiftPatterns"]),
		],
	swiftLanguageVersions:[.v5]
)
