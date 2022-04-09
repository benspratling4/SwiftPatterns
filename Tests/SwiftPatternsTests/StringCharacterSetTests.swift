//
//  StringCharacterSetTests.swift
//  
//
//  Created by Ben Spratling on 4/9/22.
//

import Foundation
import XCTest
import SwiftPatterns



class StringCharacterSetTests : XCTestCase {
	
	func testReplaceCharacters() {
		let testCases:[(String, CharacterSet, String, String)] = [
			("words!", .punctuationCharacters, "g", "wordsg"),
			("Some! words", .punctuationCharacters, "g", "Someg words"),
			("Some!! words", .punctuationCharacters, "g", "Somegg words"),
			("!Some words", .punctuationCharacters, "g", "gSome words"),
		]
		for (original, characterSet, insertion, expectedResult) in testCases {
			var testString = original
			testString.replaceCharacters(from:characterSet, with:insertion)
			XCTAssertEqual(testString, expectedResult)
		}
	}
	
	func testReplacingCharacters() {
		let testCases:[(String, CharacterSet, String, String)] = [
			("words!", .punctuationCharacters, "g", "wordsg"),
			("Some! words", .punctuationCharacters, "g", "Someg words"),
			("Some!! words", .punctuationCharacters, "g", "Somegg words"),
			("!Some words", .punctuationCharacters, "g", "gSome words"),
		]
		for (original, characterSet, insertion, expectedResult) in testCases {
			XCTAssertEqual(original.replacingCharacters(from: characterSet, with: insertion), expectedResult)
		}
	}
	
	func testDeleteCharacters() {
		let testCases:[(String, CharacterSet, String)] = [
			("words!", .punctuationCharacters, "words"),
			("Some! words", .punctuationCharacters, "Some words"),
			("Some!! words", .punctuationCharacters, "Some words"),
			("!Some words", .punctuationCharacters, "Some words"),
		]
		for (original, characterSet, expectedResult) in testCases {
			var testString = original
			testString.deleteCharacters(from:characterSet)
			XCTAssertEqual(testString, expectedResult)
		}
	}
	
	func testDeletingCharacters() {
		let testCases:[(String, CharacterSet, String)] = [
			("words!", .punctuationCharacters, "words"),
			("Some! words", .punctuationCharacters, "Some words"),
			("Some!! words", .punctuationCharacters, "Some words"),
			("!Some words", .punctuationCharacters, "Some words"),
		]
		for (original, characterSet, expectedResult) in testCases {
			XCTAssertEqual(original.deletingCharacters(from: characterSet), expectedResult)
		}
	}
	
}
