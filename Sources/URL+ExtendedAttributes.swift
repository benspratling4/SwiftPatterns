//
//  URL+ExtendedAttributes.swift
//  SpratUtilities
//
//  Created by Ben Spratling on 7/14/16.
//  Copyright © 2016 benspratling.com. All rights reserved.
//

import Foundation

extension URL {
	
	public var extendedAttributes:ExtendedAttributes? {
		get {
			return ExtendedAttributes(url: self)
		}
	}
	
}

/**

ExtendedAttributes store and retrieve arbitrary data with the setxattr/getxattr functions with convenient Swift subscripting

Use it like so:

//Set:
let valueIWantToStoreAsFileMetaData:String = ...
let fileURL:URL = ...	//file URL on which I want to store the meta data
fileURL?.extendedAttributes?["MyMetaDataKey"] = valueIWantToStoreAsFileMetaData
//-----------------
//Get:
let fileURL:URL = ...	//file URL on which I want to store the meta data
if let metaData:String = fileURL.extendedAttributes?["MyMetaDataKey"]

Note that because there are different subscript operators for Data, and a convenience for a String, you need to have the type of the value declared explicitly:
//when getting:
let metaData:String = fileURL.extendedAttributes?["MyMetaDataKey"]

//And when setting nil, which removes the value:
let data:Data?
fileURL?.extendedAttributes?["MyMetaDataKey"] = data

//There is almost no error handling at this time.
*/

open class ExtendedAttributes {
	open let url:URL
	public init?(url:URL) {
		self.url = url
		if url.scheme != "file"  {
			return nil
		}
	}
	
	open subscript(key:String)->Data? {
		get {
			//If it's possible to get a file system representation, we'll init the data
			var finalData:Data? = nil
			url.withUnsafeFileSystemRepresentation({ (systemPath)->() in
				let bufferLength:Int = getxattr(systemPath, key, nil, 0, 0, 0)
				if bufferLength == -1 {
					return
				}
				let buffer:UnsafeMutableRawPointer = UnsafeMutableRawPointer.allocate(bytes: bufferLength, alignedTo:8)	//any idea of what "aligned to" means?
				if getxattr(systemPath, key, buffer, bufferLength, 0, 0) == -1 {
					free(buffer)
					return
				}
				finalData = Data(bytesNoCopy: buffer, count: bufferLength, deallocator:.free)
			})
			return finalData
		}
		set (newValue) {
			if let newData:Data = newValue {
				newData.withUnsafeBytes({ (buffer) -> Void in
					url.withUnsafeFileSystemRepresentation({ (systemPath) in
						setxattr(systemPath, key, buffer, newData.count, 0, 0)	//fail is ==-1
					})
				})
			} else {
				//remove any value here
				url.withUnsafeFileSystemRepresentation({ (systemPath)->() in
					removexattr(systemPath, key, 0)
				})
			}
		}
	}
	
	open subscript(key:String)->String? {
		get {
			guard let data:Data = self[key] else {
				return nil
			}
			return String(data: data, encoding: .utf8)
		}
		set (newValue) {
			self[key] = newValue?.data(using:.utf8)
		}
	}
	
}
