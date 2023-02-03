//
//  NetworkDecoder.swift
//  
//
//  Created by Ben Spratling on 9/27/22.
//

import Foundation
import Combine


///tired of different decoders and objects representing a cohesive response from your network?
///Use this one type to bind them all
///Your HeadersType should have only top-level fields which have the names of their header fields as the key values
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0,  *)
public struct NetworkDecoding<BodyType, HeadersType> where BodyType : Decodable, HeadersType : Decodable {
	public var body:BodyType
	public var headers:HeadersType
	
	public init(body:BodyType, headers:HeadersType) {
		self.body = body
		self.headers = headers
	}
}


///And use this decoder to decode the response from a tuple returned by the url session data publisher
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0,  *)
public struct NetworkDecoder {
	
	public init() {
	}
	
	public func decode<BodyType, HeadersType>(_ networkDecoding:NetworkDecoding<BodyType, HeadersType>.Type, from dataAndResponse:(data:Data, response:URLResponse))throws-> NetworkDecoding<BodyType, HeadersType> {
		let headerDecoder = HTTPResponseDecoder(fieldDecoders: headerFieldDecoders)
		let headersValue:HeadersType = try headerDecoder.decode(HeadersType.self, from: dataAndResponse.response)
		let bodyDecoder = JSONDecoder()
		bodyDecoder.dateDecodingStrategy = dateDecodingStrategy
		let body = try bodyDecoder.decode(BodyType.self, from: dataAndResponse.data)
		return NetworkDecoding(body: body, headers: headersValue)
	}
	
	public var headerFieldDecoders:[String:HTTPHeaderFieldDecoder] = [:]
	
	public var bodyDecoder:JSONDecoder = JSONDecoder()
	
	///options, prefer setting properties of bodyDecoder instead
	public var dateDecodingStrategy:JSONDecoder.DateDecodingStrategy {
		get {
			bodyDecoder.dateDecodingStrategy
		}
		set {
			bodyDecoder.dateDecodingStrategy = newValue
		}
	}
	
}



@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0,  *)
public class HTTPResponseDecoder : TopLevelDecoder {
	
	public init(fieldDecoders:[String:HTTPHeaderFieldDecoder] = HTTPResponseDecoder.standardFieldDecoders) {
		self.fieldDecoders = fieldDecoders
	}
	
	public var fieldDecoders:[String:HTTPHeaderFieldDecoder]
	
	public static let standardFieldDecoders:[String:HTTPHeaderFieldDecoder] = [:]
	
	
	//MARK: - TopLevelDecoder
	
	public func decode<T>(_ typeToDecode:T.Type, from urlResponse: URLResponse) throws -> T where T : Decodable {
		guard let httpResponse = urlResponse as? HTTPURLResponse else {
			throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "the response is not an HTTPURLResponse"))
		}
		let decoder = HTTPResponseContainerDecoder(httpResponse: httpResponse, fieldDecoders: fieldDecoders)
		
		return try typeToDecode.init(from: decoder)
	}
	
}


///A decoder which can create instances from a string
public protocol HTTPHeaderFieldDecoder {
	
	//MARK: - TopLevelDecoder
	
	func decode<T>(_ typeToDecode:T.Type, from string: String) throws -> T
}


@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
struct HTTPHeadersKeyedDecodingContainer<Key> : KeyedDecodingContainerProtocol where Key: CodingKey {
	
	init(response:HTTPURLResponse, keyedBy keyType:Key.Type, fieldDecoders:[String:HTTPHeaderFieldDecoder]) {
		self.response = response
		self.keyType = keyType
		self.fieldDecoders = fieldDecoders
	}
	
	let keyType:Key.Type
	
	let response:HTTPURLResponse
	
	//keys are CodingKey string values
	//
	var fieldDecoders:[String:HTTPHeaderFieldDecoder] = [:]
	
	
	//MARK: - KeyedDecodingContainerProtocol
	
	var codingPath: [CodingKey] {
		return []
	}
	
	var allKeys: [Key] {
		return response
			.allHeaderFields
			.keys
			.compactMap({ $0 as? String })
			.compactMap({ Key(stringValue: $0) })
	}
	
	func contains(_ key: Key) -> Bool {
		return response.value(forHTTPHeaderField: key.stringValue) != nil
	}
	
	func decodeNil(forKey key: Key) throws -> Bool {
		return response.value(forHTTPHeaderField: key.stringValue) == nil
	}
	
	func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		return (stringValue as NSString).boolValue
	}
	
	func decode(_ type: String.Type, forKey key: Key) throws -> String {
		guard let value = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		return value
	}
	
	func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = Double(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = Float(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = Int(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = Int8(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = Int16(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = Int32(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = Int64(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = UInt(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = UInt8(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = UInt16(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = UInt32(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let value = UInt64(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return value
	}
	
	func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable, T : LosslessStringConvertible {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		guard let converted = type.init(stringValue) else {
			throw DecodingError.typeMismatch(type, .init(codingPath: [key], debugDescription: "unable to convert \(stringValue) to \(type)"))
		}
		return converted
	}
	
	
	func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
		guard let stringValue = response.value(forHTTPHeaderField: key.stringValue) else {
			throw DecodingError.keyNotFound(key, .init(codingPath: [key], debugDescription: "no http header for \(key)"))
		}
		if let stringConvertible = type as? LosslessStringConvertible.Type {
			if let value = stringConvertible.init(stringValue) as? T {
				return value
			}
		}
		guard let decoder = fieldDecoders[key.stringValue] else {
			throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "No field decoder found for http header field \(key)")
		}
		
		return try decoder.decode(type, from: stringValue)
	}
	
	func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
		throw DecodingError.dataCorrupted(.init(codingPath: [key], debugDescription: "NetworkDecoder does not support func func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key)"))
	}
	
	func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
		throw DecodingError.dataCorrupted(.init(codingPath: [key], debugDescription: "NetworkDecoder does not support func func nestedUnkeyedContainer(forKey key: Key)"))
	}
	
	func superDecoder() throws -> Decoder {
		//what?
		throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "NetworkDecoder does not support func superDecoder()"))
	}
	
	func superDecoder(forKey key: Key) throws -> Decoder {
		//what?
		throw DecodingError.dataCorrupted(.init(codingPath: [key], debugDescription: "NetworkDecoder does not support func superDecoder(forKey key: Key)"))
	}
}

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0,  *)
struct HTTPResponseContainerDecoder : Decoder {
	
	init(httpResponse:HTTPURLResponse, fieldDecoders:[String:HTTPHeaderFieldDecoder] = [:]) {
		self.httpResponse = httpResponse
		self.fieldDecoders = fieldDecoders
	}
	
	let httpResponse:HTTPURLResponse
	
	let fieldDecoders:[String:HTTPHeaderFieldDecoder]
	
	var codingPath: [CodingKey] = []
	
	var userInfo: [CodingUserInfoKey : Any] = [:]
	
	func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
		return KeyedDecodingContainer(HTTPHeadersKeyedDecodingContainer(response: httpResponse, keyedBy: type, fieldDecoders: fieldDecoders))
	}
	
	func unkeyedContainer() throws -> UnkeyedDecodingContainer {
		fatalError()
	}
	
	func singleValueContainer() throws -> SingleValueDecodingContainer {
		fatalError()
	}
	
}


extension URL : LosslessStringConvertible {
	public init?(_ description: String) {
		self.init(string:description)
	}
}

