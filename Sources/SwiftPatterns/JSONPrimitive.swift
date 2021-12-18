//
//  JSONPrimitive.swift
//  
//
//  Created by Ben Spratling on 12/18/21.
//

import Foundation


///When someone is like "hey, let's throw some random stuff in a json object without predetermined keys and types"
///but you still want to make it Decodable
public enum JSONPrimitive : Hashable {
	case boolean(Bool)
	case integer(Int)
	case float(Double)
	case string(String)
	case array([JSONPrimitive])
	case object([String:JSONPrimitive])
	case null
}


public enum JSONPrimitiveDecodingError : Error {
	case unknownFormat
}


extension JSONPrimitive : Decodable {
	
	public init(from decoder: Decoder) throws {
		if var arrayContainer:UnkeyedDecodingContainer = try? decoder.unkeyedContainer() {
			var primitives:[JSONPrimitive] = []
			while let primitive = try? arrayContainer.decode(JSONPrimitive.self) {
				primitives.append(primitive)
			}
			self = .array(primitives)
		}
		else if let objectContainer:KeyedDecodingContainer<DynamicCodingKeys> = try? decoder.container(keyedBy: DynamicCodingKeys.self) {
			var values:[String:JSONPrimitive] = [:]
			for key in objectContainer.allKeys {
				if let value = try? objectContainer.decode(JSONPrimitive.self, forKey: key) {
					values[key.stringValue] = value
				}
			}
			self = .object(values)
		}
		else  {
			let container:SingleValueDecodingContainer = try decoder.singleValueContainer()
			if let boolean:Bool = try? container.decode(Bool.self) {
				self = .boolean(boolean)
			}
			else if let integer:Int = try? container.decode(Int.self) {
				self = .integer(integer)
			}
			else if let float:Double = try? container.decode(Double.self) {
				self = .float(float)
			}
			else if let string:String = try? container.decode(String.self) {
				self = .string(string)
			}
			else {
				self = .null
			}
		}
	}
	
}



extension JSONPrimitive : Encodable {
	public func encode(to encoder: Encoder) throws {
		switch self  {
		case .boolean(let value):
			var container = encoder.singleValueContainer()
			try container.encode(value)
			
		case .integer(let value):
			var container = encoder.singleValueContainer()
			try container.encode(value)
			
		case .float(let value):
			var container = encoder.singleValueContainer()
			try container.encode(value)
			
		case .string(let value):
			var container = encoder.singleValueContainer()
			try container.encode(value)
			
		case .array(let values):
			var container = encoder.unkeyedContainer()
			for item in values {
				try container.encode(item)
			}
			
		case .object(let keysAndValues):
			var container = encoder.container(keyedBy: DynamicCodingKeys.self)
			for (key, value) in keysAndValues {
				guard let codingKey = DynamicCodingKeys(stringValue: key) else { continue }
				try container.encode(value, forKey: codingKey)
			}
			
		case .null:
			var container = encoder.singleValueContainer()
			let nullValue:String? = nil
			try container.encode(nullValue)
		}
	}
	
}

extension JSONPrimitive : ExpressibleByBooleanLiteral {
	public init(booleanLiteral value: Bool) {
		self = .boolean(value)
	}
}

extension JSONPrimitive : ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int) {
		self = .integer(value)
	}
}

extension JSONPrimitive : ExpressibleByFloatLiteral {
	public init(floatLiteral value: Double) {
		self = .float(value)
	}
}

extension JSONPrimitive : ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self = .string(value)
	}
}

extension JSONPrimitive : ExpressibleByArrayLiteral {
	public init(arrayLiteral elements: JSONPrimitive...) {
		self = .array(elements)
	}
}

extension JSONPrimitive : ExpressibleByDictionaryLiteral {
	public init(dictionaryLiteral elements: (String, JSONPrimitive)...) {
		let dict:[String:JSONPrimitive] = [String:JSONPrimitive](uniqueKeysWithValues: elements)
		self = .object(dict)
	}
}
