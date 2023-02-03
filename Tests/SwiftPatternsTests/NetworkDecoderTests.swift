//
//  NetworkDecoderTests.swift
//  
//
//  Created by Ben Spratling on 1/27/23.
//

import XCTest
import Foundation
import SwiftPatterns


final class NetworkDecoderTests: XCTestCase {

	struct SimpleJsonBody : Codable {
		var someProperty:String
	}
	
	struct NoHttpHeaders : Codable {
	}
	
	func testNoHeaderFields() throws {
		let bodyJson = """
{
"someProperty":"someValue"
}
""".data(using: .utf8)!
		let response:URLResponse = HTTPURLResponse(url: URL(string:"https://example.com/test1")!, statusCode: 200, httpVersion: "1.1", headerFields: [
			"Content-Length":"\(bodyJson.count)",
			"Content-Type":"application/json; charset=utf-8",
		])!
		let decoder = NetworkDecoder()
		let result = try decoder.decode(NetworkDecoding<SimpleJsonBody, NoHttpHeaders>.self
										, from: (data:bodyJson, response:response))
		XCTAssertEqual(result.body.someProperty, "someValue")
	}
	
	
	struct OneStringHttpHeader : Codable {
		var customheaderField:String
		enum CodingKeys : String, CodingKey {
			case customheaderField = "Custom-Header-Field"
		}
	}
	
	
	func testStringHeaderField() throws {
		let bodyJson = """
{
"someProperty":"someValue"
}
""".data(using: .utf8)!
		let response:URLResponse = HTTPURLResponse(url: URL(string:"https://example.com/test1")!, statusCode: 200, httpVersion: "1.1", headerFields: [
			"Content-Length":"\(bodyJson.count)",
			"Content-Type":"application/json; charset=utf-8",
			"custom-header-field":"someHeaderValue"
		])!
		let decoder = NetworkDecoder()
		let result = try decoder.decode(NetworkDecoding<SimpleJsonBody, OneStringHttpHeader>.self
										, from: (data:bodyJson, response:response))
		XCTAssertEqual(result.body.someProperty, "someValue")
		XCTAssertEqual(result.headers.customheaderField, "someHeaderValue")
	}
	
	
	struct SimpleCustomHeaderFieldDecoder : HTTPHeaderFieldDecoder {
		
		func decode<T>(_ typeToDecode:T.Type, from string: String) throws -> T {
			throw DecodingError.typeMismatch(typeToDecode, .init(codingPath: [], debugDescription: "\(self) only supports decoding Int"))
		}
		
		func decode(_ typeToDecode:Int.Type, from string: String) throws -> Int {
			guard let value = Int(string) else {
				throw DecodingError.typeMismatch(typeToDecode, .init(codingPath: [], debugDescription: "unable to convert \(string) to Int"))
			}
			return value
		}
	}
	
	struct OneCustomerHttpHeader : Codable {
		var customHeaderField:Int
		enum CodingKeys : String, CodingKey {
			case customHeaderField = "Custom-Header-Field"
		}
	}
	
	func testCustomFieldDecoder() throws {
		
		let bodyJson = """
{
"someProperty":"someValue"
}
""".data(using: .utf8)!
		let response:URLResponse = HTTPURLResponse(url: URL(string:"https://example.com/test1")!, statusCode: 200, httpVersion: "1.1", headerFields: [
			"Content-Length":"\(bodyJson.count)",
			"Content-Type":"application/json; charset=utf-8",
			"custom-header-field":"12346"
		])!
		var decoder = NetworkDecoder()
		decoder.headerFieldDecoders["Custom-Header-Field"] = SimpleCustomHeaderFieldDecoder()
		let result = try decoder.decode(NetworkDecoding<SimpleJsonBody, OneCustomerHttpHeader>.self
										, from: (data:bodyJson, response:response))
		XCTAssertEqual(result.body.someProperty, "someValue")
		XCTAssertEqual(result.headers.customHeaderField, 12346)
	}
	
	
	struct OneIntHttpHeader : Codable {
		var customHeaderField:Int
		enum CodingKeys : String, CodingKey {
			case customHeaderField = "Custom-Header-Field"
		}
	}
	
	
	func testIntDecoder() throws {
		let bodyJson = """
{
"someProperty":"someValue"
}
""".data(using: .utf8)!
		let response:URLResponse = HTTPURLResponse(url: URL(string:"https://example.com/test1")!, statusCode: 200, httpVersion: "1.1", headerFields: [
			"Content-Length":"\(bodyJson.count)",
			"Content-Type":"application/json; charset=utf-8",
			"custom-header-field":"12346"
		])!
		let decoder = NetworkDecoder()
		let result = try decoder.decode(NetworkDecoding<SimpleJsonBody, OneIntHttpHeader>.self
										, from: (data:bodyJson, response:response))
		XCTAssertEqual(result.body.someProperty, "someValue")
		XCTAssertEqual(result.headers.customHeaderField, 12346)
	}
	
	
	struct OoptionalStringHttpHeader : Codable {
		var customheaderField:String?
		enum CodingKeys : String, CodingKey {
			case customheaderField = "Custom-Header-Field"
		}
	}
	
	
	func testOptionalStringHeaderFieldNil() throws {
		let bodyJson = """
{
"someProperty":"someValue"
}
""".data(using: .utf8)!
		let response:URLResponse = HTTPURLResponse(url: URL(string:"https://example.com/test1")!, statusCode: 200, httpVersion: "1.1", headerFields: [
			"Content-Length":"\(bodyJson.count)",
			"Content-Type":"application/json; charset=utf-8",
			//the header in question is absent
		])!
		let decoder = NetworkDecoder()
		let result = try decoder.decode(NetworkDecoding<SimpleJsonBody, OoptionalStringHttpHeader>.self
										, from: (data:bodyJson, response:response))
		XCTAssertEqual(result.body.someProperty, "someValue")
		XCTAssertNil(result.headers.customheaderField)
	}
	
	
	func testOptionalStringHeaderFieldNonNil() throws {
		let bodyJson = """
{
"someProperty":"someValue"
}
""".data(using: .utf8)!
		let response:URLResponse = HTTPURLResponse(url: URL(string:"https://example.com/test1")!, statusCode: 200, httpVersion: "1.1", headerFields: [
			"Content-Length":"\(bodyJson.count)",
			"Content-Type":"application/json; charset=utf-8",
			"custom-header-field":"12346"
		])!
		let decoder = NetworkDecoder()
		let result = try decoder.decode(NetworkDecoding<SimpleJsonBody, OoptionalStringHttpHeader>.self
										, from: (data:bodyJson, response:response))
		XCTAssertEqual(result.body.someProperty, "someValue")
		XCTAssertEqual(result.headers.customheaderField, "12346")
	}
	
	
	func testMismatchIntToString() throws {
		let bodyJson = """
{
"someProperty":"someValue"
}
""".data(using: .utf8)!
		let response:URLResponse = HTTPURLResponse(url: URL(string:"https://example.com/test1")!, statusCode: 200, httpVersion: "1.1", headerFields: [
			"Content-Length":"\(bodyJson.count)",
			"Content-Type":"application/json; charset=utf-8",
			"custom-header-field":"abc123u&me"
		])!
		let decoder = NetworkDecoder()
		XCTAssertThrowsError(try decoder.decode(NetworkDecoding<SimpleJsonBody, OneIntHttpHeader>.self
												, from: (data:bodyJson, response:response))) { error in
			guard case DecodingError.typeMismatch(_, let context) = error else {
				XCTFail("This error should have been a DecodingError.typeMismatch")
				return
			}
			guard let keyName = context.codingPath.first?.stringValue else {
				XCTFail("failed key path wasn't the expected type")
				return
			}
			XCTAssertEqual(keyName, "Custom-Header-Field")
		}
	}
	
	
	///assumes the header field is utf8 json
	struct ArbitraryJsonObjectHeaderDecoder<Kind> : HTTPHeaderFieldDecoder where Kind : Decodable {
		
		var kind:Kind.Type
		
		func decode<T>(_ typeToDecode: T.Type, from string: String) throws -> T {
			guard let data:Data = string.data(using: .utf8) else {
				throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "header field was not utf8"))
			}
			let value = try jsonDecoder.decode(kind, from: data)
			guard let valueT = value as? T else {
				throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Using ArbitraryJsonObjectHeaderFielDecoder but \(typeToDecode) does not conform to decodable"))
			}
			return valueT
		}
		
		var jsonDecoder:JSONDecoder = JSONDecoder()
		
		
	}
	
	
	struct HeaderContainingJsonThing : Decodable {
		var customHeaderField:SimpleJsonBody
		enum CodingKeys : String, CodingKey {
			case customHeaderField = "Custom-Header-Field"
		}
	}
	
	func testCustomJsondecoder() throws {
		let bodyJson = """
{
"someProperty":"someValue"
}
""".data(using: .utf8)!
		let response:URLResponse = HTTPURLResponse(url: URL(string:"https://example.com/test1")!, statusCode: 200, httpVersion: "1.1", headerFields: [
			"Content-Length":"\(bodyJson.count)",
			"Content-Type":"application/json; charset=utf-8",
			"custom-header-field":"{\"someProperty\":\"another value\"}"
		])!
		var decoder = NetworkDecoder()
		decoder.headerFieldDecoders["Custom-Header-Field"] = ArbitraryJsonObjectHeaderDecoder(kind: SimpleJsonBody.self)
		let result = try decoder.decode(NetworkDecoding<SimpleJsonBody, HeaderContainingJsonThing>.self
										, from: (data:bodyJson, response:response))
		XCTAssertEqual(result.body.someProperty, "someValue")
		
		XCTAssertEqual(result.headers.customHeaderField.someProperty, "another value")
	}
	
	
	
	//TODO: test more errors

}
