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
