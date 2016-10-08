//
//  NonNilArrayTests.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 10/8/16.
//  Copyright © 2016 benspratling.com. All rights reserved.
//

import XCTest

import SwiftPatterns

class NonNilArrayTests: XCTestCase {

    func testEmpty() {
		let values:[Int?] = []
		let nonNilValues:[Int] = values.nonNilElements
		XCTAssertEqual([], nonNilValues)
    }
	
	
	func testAllNonNil() {
		let values:[Int?] = [1,2,3,4,5,6,7,8]
		let nonNilValues:[Int] = values.nonNilElements
		XCTAssertEqual([1,2,3,4,5,6,7,8], nonNilValues)
	}
	
	
	func testSomeNonNil() {
		let values:[Int?] = [1,2,nil,4,5,nil,7,8]
		let nonNilValues:[Int] = values.nonNilElements
		XCTAssertEqual([1,2,4,5,7,8], nonNilValues)
	}
	
	func testAllNil() {
		let values:[Int?] = [nil, nil, nil, nil]
		let nonNilValues:[Int] = values.nonNilElements
		XCTAssertEqual([], nonNilValues)
	}
	
}
