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
		//TODO: can this be done without allocating a Data?
		//does a sub-data use a reference?
		return subdata(in: index..<(index+width)).withUnsafeBytes({ return $0.pointee })
	}
	
	///apend bytes for the given POD type
	public mutating func append<ContentType>(value:ContentType) {
		var valueCopy:ContentType = value
		let dataSize:Int = MemoryLayout<ContentType>.size
		let rawPointer = UnsafeRawPointer(UnsafeMutablePointer(&valueCopy))
		let tempData = Data(bytes:rawPointer, count: dataSize)
		self.append(tempData)
	}
}
