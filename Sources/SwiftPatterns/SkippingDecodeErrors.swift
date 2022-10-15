//
//  File.swift
//  
//
//  Created by Benjamin Spratling on 10/14/22.
//

import Foundation

/**
 When your array needs to be decodable, but needs to not fail everything if one of the items fails to decode.
 */
@propertyWrapper public struct SkippingDecodeErrors<Value> : Decodable where Value : Decodable {
	
	public init(wrappedValue:[Value]) {
		self.wrappedValue = wrappedValue
	}
	
	public var wrappedValue:[Value]
	
	public init(from decoder: Decoder) throws {
		var values:[Value] = []
		var container = try decoder.unkeyedContainer()
		while !container.isAtEnd {
			if let value = try? container.decode(Value.self) {
				values.append(value)
			}
			else {
				//if the container fails to decode the thing, it will not advance the index
				//so we make it decode a type that doesn't end up exercising any failures
				_ = try container.decode(EmptyType.self)
			}
		}
		self.wrappedValue = values
	}
	
	private struct EmptyType : Decodable {}
	
}

public extension SkippingDecodeErrors where Value : Encodable {
	func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
}

extension SkippingDecodeErrors : Equatable where Value: Equatable { }

extension SkippingDecodeErrors : Hashable where Value : Hashable { }
