//
//  String+Precautionary.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 3/23/25.
//

import Foundation
import XCTest
import SwiftPatterns




class StringReplaceWithPrecautionaryWhitespaceTests : XCTestCase {
	
	func testHasLeadingCharSets() {
		let string = " erfe rfu"
		let afterSpaceIndex = string.index(string.startIndex, offsetBy: 1)
		
		XCTAssertTrue(string.has(characterSet: .whitespacesAndNewlines, before: afterSpaceIndex))
		XCTAssertFalse(string.has(characterSet: .whitespacesAndNewlines, after: afterSpaceIndex))
		
		
		let beforeSpaceIndex = string.index(string.startIndex, offsetBy: 5)
		
		XCTAssertFalse(string.has(characterSet: .whitespacesAndNewlines, before: beforeSpaceIndex))
		XCTAssertTrue(string.has(characterSet: .whitespacesAndNewlines, after: beforeSpaceIndex))
	}
	
	
	func testNeedsWhitespaceBefore() {
		let testCases:[(host:String, insertion:String, location:Int, count:Int, needsLeading:Bool, needsTrailing:Bool, result:String, newIndex:Int)] = [
			(" erfe  rfu", "something", 0, 0, false, false, "something erfe  rfu", 9),
			(" erfe  rfu", "something", 0, 1, false, true, "something erfe  rfu", 10),
			(" erfe  rfu", "something", 1, 0, false, true, " something erfe  rfu", 11),
			(" erfe  rfu", "something", 2, 0, true, true, " e something rfe  rfu", 13),
			(" erfe  rfu", "something", 10, 0, true, false, " erfe  rfu something", 20),
			(" erfe  rfu", " something", 10, 0, false, false, " erfe  rfu something", 20),
			(" erfe  rfu ", "something", 11, 0, false, false, " erfe  rfu something", 20),
			(" erfe  rfu", " something", 2, 0, false, true, " e something rfe  rfu", 13),
			(" erfe  rfu", "something ", 2, 0, true, false, " e something rfe  rfu", 13),
			(" erfe  rfu", " something ", 2, 0, false, false, " e something rfe  rfu", 13),
			(" erfe  rfu", "something", 6, 0, false, false, " erfe something rfu", 15),
			(" erfe  rfu", "something", 5, 2, true, true, " erfe something rfu", 16),
			
			
			//tests with punctuation
			(" ! rfe  rfu", "something", 0, 1, false, false, "something! rfe  rfu", 9),
			(" ! rfe  rfu", "something,", 0, 1, false, true, "something, ! rfe  rfu", 11),
			("After?", "¿something?", 6, 0, true, false, "After? ¿something?", 18),
			("After?", "! something?", 5, 0, false, true, "After! something? ?", 18),
			("After? ", "¿something?", 7, 0, false, false, "After? ¿something?", 18),
			("After? And then some", "¿something?", 7, 0, false, true, "After? ¿something? And then some", 19),
			
		]
		
		for (host, insertion, location, count, needsLeading, needsTrailing, result, newIndex) in testCases {
			let range = host.makeRange(location: location, count: count)
			let (leading, trailing) = host.needsPrecautionaryWhitespace(insertion, at: range)
			XCTAssertEqual(leading, needsLeading)
			XCTAssertEqual(trailing, needsTrailing)
			let (output, newInsertionIndex) = host.replacingWithPrecautionaryWhitespace(insertion, at: range)
			XCTAssertEqual(result, output)
			XCTAssertEqual(output.distance(from: output.startIndex, to: newInsertionIndex), newIndex)
		}
	}
	
	
	
}


extension String {
	
	func makeRange(location:Int, count:Int)->Range<String.Index> {
		index(startIndex, offsetBy: location)..<index(startIndex, offsetBy: location + count)
	}
	
}
