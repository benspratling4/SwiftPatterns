//
//  File.swift
//  
//
//  Created by Ben Spratling on 3/6/22.
//

import Foundation
import XCTest
import SwiftPatterns



class StringFixesTests: XCTestCase {
	
	func testPrefixEmpty() {
		let original:String = ""
		XCTAssertNil(original.withoutPrefix("a"))
	}
	
	func testSuffixEmpty() {
		let original:String = ""
		XCTAssertNil(original.withoutSuffix("a"))
	}
	
	func testPrefixWrongCharacter() {
		let original:String = "b"
		XCTAssertNil(original.withoutPrefix("a"))
	}
	
	func testSuffixWrongCharacter() {
		let original:String = "b"
		XCTAssertNil(original.withoutSuffix("a"))
	}
	
	func testPrefixMatchingWholeStringLength1() {
		let original:String = "b"
		guard let value = original.withoutPrefix("b") else {
			XCTFail()
			return
		}
		XCTAssertEqual(value, "")
	}
	
	func testSuffixMatchingWholeStringLength1() {
		let original:String = "b"
		guard let value = original.withoutSuffix("b") else {
			XCTFail()
			return
		}
		XCTAssertEqual(value, "")
	}
	
	func testPrefixMatchingPartialStringLength2() {
		let original:String = "bc"
		guard let value = original.withoutPrefix("b") else {
			XCTFail()
			return
		}
		XCTAssertEqual(value, "c")
	}
	
	func testSuffixMatchingPartialStringLength2() {
		let original:String = "cb"
		guard let value = original.withoutSuffix("b") else {
			XCTFail()
			return
		}
		XCTAssertEqual(value, "c")
	}
	
	
}
