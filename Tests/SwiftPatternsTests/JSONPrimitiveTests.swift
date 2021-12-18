//
//  JSONPrimitiveTests.swift
//  
//
//  Created by Ben Spratling on 12/18/21.
//

import Foundation

import XCTest
import SwiftPatterns

class JSONPrimitiveTests: XCTestCase {
	
	func testBooleanDecode() throws {
		let trueValue = try JSONDecoder().decode(JSONPrimitive.self, from: "true".data(using: .utf8)!)
		XCTAssertEqual(trueValue, .boolean(true))
		
		let falseValue = try JSONDecoder().decode(JSONPrimitive.self, from: "false".data(using: .utf8)!)
		XCTAssertEqual(falseValue, .boolean(false))
		
		if let _ = try? JSONDecoder().decode(JSONPrimitive.self, from: "yes".data(using: .utf8)!) {
			XCTFail("shouldn't have been able to decode that")
		}
	}
	
	func testIntegerDecode() throws {
		let testCases:[(String, JSONPrimitive)] = [
			("-13", .integer(-13)),
			("6783482039", .integer(6783482039)),
		]
		
		for (stringValue, jsonValue) in testCases {
			let data:Data = stringValue.data(using: .utf8)!
			let decoded = try JSONDecoder().decode(JSONPrimitive.self, from: data)
			XCTAssertEqual(decoded, jsonValue)
		}
	}
	
	
	func testFloatDecode() throws {
		let testCases:[(String, Double, Double)] = [
			("-13.1", -13.1, 0.00001),
			("6783482039.8", 6783482039.8, 0.00001),
		]
		
		for (stringValue, jsonValue, precision) in testCases {
			let data:Data = stringValue.data(using: .utf8)!
			let decoded = try JSONDecoder().decode(JSONPrimitive.self, from: data)
			guard case .float(let fValue) = decoded else {
				XCTFail("shouldn't have been able to decode that")
				continue
			}
			XCTAssertEqual(fValue, jsonValue, accuracy: precision)
		}
	}
	
	func testStringDecode() throws {
		let testCases:[(String, JSONPrimitive)] = [
			("\"\"", .string("")),
			("\"a\"", .string("a")),
			("\"abcdefghijklmnopqrstuvwxyz\"", .string("abcdefghijklmnopqrstuvwxyz")),
		]
		
		for (stringValue, jsonValue) in testCases {
			let data:Data = stringValue.data(using: .utf8)!
			let decoded = try JSONDecoder().decode(JSONPrimitive.self, from: data)
			XCTAssertEqual(decoded, jsonValue)
		}
	}
	
	func testArrayDecode() throws {
		let testCases:[(String, JSONPrimitive)] = [
			//empty case
			("[]", .array([])),
			//single item case
			("[\"a\"]", .array([.string("a")])),
			//multi item case
			("[\"a\", 1234]", .array([.string("a"), .integer(1234)])),
			//recursive case
			("[[5]]", .array([.array([.integer(5)])])),
			//internal boolean
			("[true]", .array([.boolean(true)])),
			//internal object
			("[{}]", .array([.object([:])])),
			//internal float - requires testing with accuracy
//			("[1234.5678]", .array([.float(1234.5678)])),
		]
		
		for (stringValue, jsonValue) in testCases {
			let data:Data = stringValue.data(using: .utf8)!
			let decoded = try JSONDecoder().decode(JSONPrimitive.self, from: data)
			XCTAssertEqual(decoded, jsonValue)
		}
	}
	
	func testNullDecode() throws {
		let testCases:[(String, JSONPrimitive)] = [
			("null", .null),
		]
		
		for (stringValue, jsonValue) in testCases {
			let data:Data = stringValue.data(using: .utf8)!
			let decoded = try JSONDecoder().decode(JSONPrimitive.self, from: data)
			XCTAssertEqual(decoded, jsonValue)
		}
	}
	
	
	func testObjectDecode() throws {
		let testCases:[(String, JSONPrimitive)] = [
			//empty case
			("{}", .object([:])),
			//single item case
			("{\"a\":12345}", .object(["a":.integer(12345)])),
			//multi item case
			("{\"a\":12345, \"b\":\"abc\"}", .object(["a":.integer(12345), "b":.string("abc")])),
			//recursive case
			("{\"a\":{}}", .object(["a":.object([:])])),
		]
		
		for (stringValue, jsonValue) in testCases {
			let data:Data = stringValue.data(using: .utf8)!
			let decoded = try JSONDecoder().decode(JSONPrimitive.self, from: data)
			XCTAssertEqual(decoded, jsonValue)
		}
	}
	
	
	func testIntegerEncode() throws {
		let testCases:[(String, JSONPrimitive)] = [
			("-13", .integer(-13)),
			("6783482039", .integer(6783482039)),
		]
		
		for (stringValue, jsonValue) in testCases {
			let data:Data = stringValue.data(using: .utf8)!
			let encodedData = try JSONEncoder().encode(jsonValue)
			XCTAssertEqual(data, encodedData)
		}
	}
	
	
	func testArrayEncode() throws {
		let testCases:[(String, JSONPrimitive)] = [
			("[-13,68,39,6789]", .array([.integer(-13), .integer(68), .integer(39), .integer(6789)])),
		]
		
		for (stringValue, jsonValue) in testCases {
			let data:Data = stringValue.data(using: .utf8)!
			let encodedData = try JSONEncoder().encode(jsonValue)
			XCTAssertEqual(data, encodedData)
		}
	}
	
	
	func testObjectEncode() throws {
		let testCases:[(String, JSONPrimitive)] = [
			("{\"a\":-13}", .object(["a":.integer(-13)])),
		]
		
		for (stringValue, jsonValue) in testCases {
			let data:Data = stringValue.data(using: .utf8)!
			let encodedData = try JSONEncoder().encode(jsonValue)
			XCTAssertEqual(data, encodedData)
		}
	}
	
	func testBooleanLiteralInit() {
		let primitive:JSONPrimitive = true
		XCTAssertEqual(JSONPrimitive.boolean(true), primitive)
	}
	
	func testIntegerLiteralInit() {
		let primitive:JSONPrimitive = 16793
		XCTAssertEqual(JSONPrimitive.integer(16793), primitive)
	}
	
	func testStringLiteralInit() {
		let primitive:JSONPrimitive = "123abcu&me"
		XCTAssertEqual(JSONPrimitive.string("123abcu&me"), primitive)
	}
	
	func testArrayLiteralInit() {
		let primitive:JSONPrimitive = ["123abcu&me", true, 23489, 34587.245]
		XCTAssertEqual(JSONPrimitive.array([.string("123abcu&me"), .boolean(true), .integer(23489), .float(34587.245)]), primitive)
	}
	
}
