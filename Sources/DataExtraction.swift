//
//  DataExtraction.swift
//  FoundationZip
//
//  Created by Ben Spratling on 10/9/16.
//
//

import Foundation

extension Data {
	///I have no idea why extracting a simple POD type from Data is so hard.  here it is.
	public func extract<ContentType>(at index:Int)->ContentType {
		let width:Int = MemoryLayout<ContentType>.size
		return Data(self[index..<(index+width)]).withUnsafeBytes({ (a:UnsafePointer<ContentType>) -> ContentType in
			return a.pointee
		})
	}
}
