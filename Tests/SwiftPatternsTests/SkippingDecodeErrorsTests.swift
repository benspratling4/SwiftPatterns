//
//  SkippingDecodeErrorsTests.swift
//  
//
//  Created by Benjamin Spratling on 10/14/22.
//

import XCTest
import SwiftPatterns

final class SkippingDecodeErrorsTests: XCTestCase {

	func testSkippingBadType() {
		
		let json2 = """
  {
  "someValues":
  [
  "unknown Value",
  "value1",
  "value2",
  ]
  }
  """.data(using: .utf8)!

		var someValues = try! JSONDecoder().decode(MainType.self, from: json2)
		XCTAssertEqual(someValues, MainType(someValues: [.value1, .value2]))
	}

}


fileprivate enum Choices : String, Codable, Equatable {
 case value1
 case value2
}

fileprivate struct MainType : Decodable, Equatable {
 @SkippingDecodeErrors var someValues:[Choices]
}

