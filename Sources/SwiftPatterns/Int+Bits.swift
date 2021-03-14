//
//  File.swift
//  
//
//  Created by Ben Spratling on 3/13/21.
//

import Foundation

extension UInt8 {
	
	fileprivate static let masks:[UInt8] = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80]
	fileprivate static let inverseMasks:[UInt8] = [0xFE, 0xFD, 0xFB, 0xF7, 0xEF, 0xDF, 0xBF, 0x7F]
	
	/// pull a Bool representing a bit in a byte.
	/// true == 1, false == 0
	/// `at`: 0 == least significant bit, MSb = 7
	public func bit(at:UInt8)->Bool {
		let masked:UInt8 = self & UInt8.masks[Int(at)]
		return masked != 0
	}
	
	public mutating func setBit(_ bit:Bool, at:UInt8) {
		if bit {
			self = self | UInt8.masks[Int(at)]
		} else {
			self = self & UInt8.inverseMasks[Int(at)]
		}
	}
	
}


extension Int {
	///up to an Int's worth of bits, MSB-first
	public init(bits:[Bool]) {
		var value:Int = 0
		for bit in bits {
			value = value << 1
			value += bit ? 1 : 0
		}
		self = value
	}
}
