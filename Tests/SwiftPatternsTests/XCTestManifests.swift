import XCTest

#if !os(macOS)
	public func allTests() -> [XCTestCaseEntry] {
		return [
			testCase(ChangeSetTests.allTests),
			testCase(LogSearchTests.allTests),
			testCase(XMLItemTests.allTests),
		]
	}
#endif
