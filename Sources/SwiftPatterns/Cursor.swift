//
//  File.swift
//  
//
//  Created by Ben Spratling on 3/13/21.
//

import Foundation

//The offset from the beginning of a Data at which a bit is located
public struct BitCursor : Comparable, CustomDebugStringConvertible {
	///generaly should be
	public var byte:Int
	
	///only values 0-7 are valid
	public var bit:UInt8
	
	public init(byte:Int = 0, bit:UInt8 = 0) {
		self.byte = byte
		self.bit = bit
	}
	
	///create a new cursor which is advanced by the given number of bits, and normalized
	public func adding(bits count:Int)->BitCursor {
		let newTotalBits:Int = Int(bit) + count
		return BitCursor(byte: byte + (newTotalBits / 8), bit: UInt8(newTotalBits % 8))
	}
	
	public func adding(bytes count:Int)->BitCursor {
		return BitCursor(byte: byte + count, bit: bit)
	}
	
	///round the cursor up to the next multiple of 4 bytes, or 32 bits
	public func roundingUpTo32()->BitCursor {
		var newByte:Int = byte
		if bit > 0 { newByte += 1}
		let remainder:Int = newByte % 4
		if remainder != 0{
			newByte += 4 - remainder
		}
		return BitCursor(byte:newByte, bit:0)
	}
	
	/// Equatable
	
	public static func ==(lhs:BitCursor, rhs:BitCursor)->Bool {
		return lhs.byte == rhs.byte && lhs.bit == rhs.bit
	}
	
	/// Comparable
	
	public static func <(lhs: BitCursor, rhs: BitCursor) -> Bool {
		if lhs.byte == rhs.byte { return lhs.bit < rhs.bit }
		return lhs.byte < rhs.byte
	}
	
	///CustomDebugStringConvertible
	public var debugDescription: String {
		return "\(byte):\(bit)"
	}
	
}
