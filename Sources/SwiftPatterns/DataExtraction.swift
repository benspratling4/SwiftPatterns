//
//  DataExtraction.swift
//  FoundationZip
//
//  Created by Ben Spratling on 10/9/16.
//
//

import Foundation

extension Data {
	/// View some sub-range of bytes beginning at the given index as the return type.
	/// `let value:UInt32 = data.extract(at:8)`	//converts bytes 8..<12 as an UInt32
	public func extract<ContentType>(at index:Int)->ContentType {
		let width:Int = MemoryLayout<ContentType>.size
		let unsafeBytes = UnsafeMutablePointer<ContentType>.allocate(capacity: 1)
		defer { unsafeBytes.deallocate(capacity: 1) }
		let bufferPointer = UnsafeMutableBufferPointer(start: unsafeBytes, count: 1)
		_ = self.copyBytes(to: bufferPointer, from: index..<(index + width))
		return unsafeBytes.pointee
	}
	
	///apend bytes for the given POD type
	public mutating func append<ContentType>(value:ContentType) {
		var valueCopy:ContentType = value
		withUnsafePointer(to: &valueCopy) { (pointer:UnsafePointer<ContentType>) -> Void in
			let buffer:UnsafeBufferPointer<ContentType> = UnsafeBufferPointer(start: pointer, count: 1)
			self.append(buffer)
		}
	}
}
