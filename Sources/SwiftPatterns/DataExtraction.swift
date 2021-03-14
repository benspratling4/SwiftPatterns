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
		defer { unsafeBytes.deallocate() }
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


///The factories should use the BitStream instead
extension Data {
	///these bits are LSB first, not MSB first like human writing
	public func bits(at:BitCursor, count:Int = 1)->([Bool], BitCursor) {
		var cursor:BitCursor = at
		var bits:[Bool] = []
		for _ in 0..<count {
			//get the byte at the cursor
			bits.append(self[cursor.byte].bit(at:cursor.bit))
			cursor = cursor.adding(bits: 1)
		}
		return (bits, cursor)
	}
	
	///does not use bits in reading the bytes, so bytes are always byte-aligned to the oriignal data
	public func bytes(at:BitCursor, count:Int = 1)->([UInt8], BitCursor) {
		let newBitCursor = at.adding(bytes: count)
		var bytes:[UInt8] = Array<UInt8>(repeating: 0, count: count)
		copyBytes(to: &bytes, from: at.byte..<newBitCursor.byte)
		return (bytes, newBitCursor)
	}
	
	mutating func appendBits(_ bits:[Bool], at cursor:BitCursor)->BitCursor {
		var newCursor:BitCursor = cursor
		for bitIndex in 0..<bits.count {
			var aByte:UInt8
			if newCursor.byte >= count {
				//we need to add a new byte
				aByte = 0
			} else {
				aByte = self[newCursor.byte]
			}
			aByte.setBit(bits[bitIndex], at: newCursor.bit)
			if newCursor.byte >= count {
				append(aByte)
			} else {
				self[newCursor.byte] = aByte
			}
			newCursor = newCursor.adding(bits: 1)
		}
		return newCursor
	}
}
