//
//  ArrayDropLastWhileTests.swift
//  
//
//  Created by Ben Spratling on 3/6/22.
//

import XCTest
import SwiftPatterns



class ArrayDropLastWhileTests: XCTestCase {
	
	func testEmpty() {
		let originalArray:[String] = []
		let finalValue = originalArray.dropLast(while: { $0.isEmpty })
		XCTAssertEqual(finalValue, [])
	}
	
	func testUndervalued() {
		let originalArray:[Int] = [1, 2, 3]
		let finalValue = originalArray.dropLast(while: { $0 < 5 })
		XCTAssertEqual(finalValue, [])
	}
	
	func testOvervalued() {
		let originalArray:[Int] = [1, 2, 3]
		let finalValue = originalArray.dropLast(while: { $0 > 5 })
		XCTAssertEqual(finalValue, [1, 2, 3])
	}
	
	func testMidvalued() {
		let originalArray:[Int] = [1, 2, 3]
		let finalValue = originalArray.dropLast(while: { $0 > 2 })
		XCTAssertEqual(finalValue, [1, 2])
	}
	
	func testRepeated() {
		let originalArray:[Int] = [1, 3, 3]
		let finalValue = originalArray.dropLast(while: { $0 > 2 })
		XCTAssertEqual(finalValue, [1])
	}
	
	func testRepeatedBeforeNotRepeated() {
		let originalArray:[Int] = [1, 2, 3, 2, 3]
		let finalValue = originalArray.dropLast(while: { $0 > 2 })
		XCTAssertEqual(finalValue, [1, 2, 3, 2])
	}
	
}
