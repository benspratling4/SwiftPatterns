//
//  SerializedResourceWrapping.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 10/7/16.
//  Copyright © 2016 benspratling.com. All rights reserved.
//

import Foundation

/// A base protocol which represents a resource which can be serialized
/// an example could a file, or maybe a directory, or a zip file which contains more serialized items
public protocol SerializedResourceWrapping {
	
	weak var parentResourceWrapper:SubResourceWrapping? { get set }
	
	var serializedRepresentation:Data { get }
	
	/// remember to set the parent's new name
	var lastPathComponent:String { get set }
}

/// like a directory
public protocol SubResourceWrapping : class, SerializedResourceWrapping {
	
	///access all the sub resources, usually for iteration
	/// it's also a convenience for setting the contents all at once, but don't
	var subResources:[String:SerializedResourceWrapping] { get /*set*/ }
	
	/// setting to nil removes the resource, if present
	/// This may be more efficient than iterating all sub resources
	subscript(key:String)->SerializedResourceWrapping? { get set }
	
	/// to keep names in synch
	func child(named:String, changedNameTo:String)
}


public protocol SynchronizedURLResourceWrapping : SerializedResourceWrapping {
	
	//
	func read(from url:URL) throws
	
	//overwriting is implied
	func write(to url:URL) throws
}


public protocol DataWrapping : SerializedResourceWrapping {
	var contents:Data { get set }
}

fileprivate protocol ImplementedWithFileWrapper {
	var wrapper:FileWrapper { get }
}


/// like a file wrapper
public class FileWrapping : DataWrapping, SynchronizedURLResourceWrapping {
	
	weak public var parentResourceWrapper:SubResourceWrapping?
	
	public var lastPathComponent: String {
		get {
			return wrapper.preferredFilename ?? ""
		}
		set {
			parentResourceWrapper?.child(named: lastPathComponent, changedNameTo: newValue)
			wrapper.preferredFilename = newValue
		}
	}
	
	public var contents: Data {
		get {
			return wrapper.regularFileContents ?? Data()
		}
		set {
			let newWrapper = FileWrapper(regularFileWithContents:newValue)
			newWrapper.preferredFilename = wrapper.preferredFilename
			wrapper = newWrapper
		}
	}
	
	public var serializedRepresentation: Data {
		return wrapper.serializedRepresentation ?? Data()
	}
	
	fileprivate var wrapper:FileWrapper
	
	private init(regularFileWrapper:FileWrapper) {
		self.wrapper = regularFileWrapper
	}
	
	///returns nil if the file wrapper is not a regular file
	public convenience init?(wrapper:FileWrapper) {
		if !wrapper.isRegularFile { return nil }
		self.init(regularFileWrapper:wrapper)
	}
	
	public convenience init(data:Data, name:String) {
		let wrapper = FileWrapper(regularFileWithContents:data)
		wrapper.preferredFilename = name
		self.init(wrapper:wrapper)!
	}
	
	public func read(from url:URL) throws {
		wrapper = try FileWrapper(url: url, options: [])
	}
	
	//overwriting is implied
	public func write(to url:URL) throws {
		try wrapper.write(to: url, options: [], originalContentsURL: nil)
	}
	
}


/// like a file wrapper, but only for directories
public class DirectoryWrapping : SubResourceWrapping, SynchronizedURLResourceWrapping {
	
	weak public var parentResourceWrapper:SubResourceWrapping?
	
	///must only be a directory file wrapper
	fileprivate var wrapper:FileWrapper {
		didSet {
			subWrappers = [:]
			guard let childWrappers = wrapper.fileWrappers else { return }
			for (_, aSubWrapper) in childWrappers {
				guard let childwrapper:SerializedResourceWrapping = DirectoryWrapping(directoryWrapper: aSubWrapper)
					?? FileWrapping(wrapper: aSubWrapper) else { continue }
				subWrappers[childwrapper.lastPathComponent] = childwrapper
			}
		}
	}
	
	public init?(directoryWrapper:FileWrapper) {
		if !directoryWrapper.isDirectory { return nil }
		wrapper = directoryWrapper
	}
	
	public init(wrappers:[String:SerializedResourceWrapping]) {
		//create a directory wrapper
		var subFileWrappers:[String:FileWrapper] = [:]
		for (key, subWrapper) in wrappers {
			if let fileWrapperWrapping = subWrapper as? ImplementedWithFileWrapper  {
				subFileWrappers[key] = fileWrapperWrapping.wrapper
				subWrappers[key] = subWrapper
			} else {
				//TODO: create FileWrapper or directory wrappers for unknown types
				
			}
		}
		wrapper = FileWrapper(directoryWithFileWrappers:subFileWrappers)
	}
	
	private var subWrappers:[String:SerializedResourceWrapping] = [:]
	
	public var lastPathComponent: String {
		get {
			return wrapper.preferredFilename ?? ""
		}
		set {
			parentResourceWrapper?.child(named: lastPathComponent, changedNameTo: newValue)
			wrapper.preferredFilename = newValue
		}
	}
	
	public var serializedRepresentation:Data {
		get {
			return wrapper.serializedRepresentation ?? Data()
		}
	}
	
	public var subResources:[String:SerializedResourceWrapping] {
		get {
			return subWrappers
		}
		/*	set {
		//filter out any non file or directory wrappers?
		
		}	*/
	}
	
	public subscript(key:String)->SerializedResourceWrapping? {
		get {
			return subWrappers[key]
		}
		set {
			removeWrapper(for: key)
			//verify that the object is either a directory or a file wrapper
			guard var newWrapper = newValue else {
				return
			}
			newWrapper.parentResourceWrapper = self
			subWrappers[key] = newWrapper
		}
	}
	
	private func removeWrapper(for key:String) {
		defer {
			subWrappers[key] = nil
		}
		guard var existingValue:SerializedResourceWrapping = subWrappers[key],
			let existingFileWrapper = existingValue as? ImplementedWithFileWrapper
			else { return }
		existingValue.parentResourceWrapper = nil
		wrapper.removeFileWrapper(existingFileWrapper.wrapper)
	}
	
	/** design alternatives:
	- back the directory wrapping with a file wrapper - direct, no confusion, inefficient
	- extract all sub-direcotry wrapper into ResourceWrapping
	- extract only regular files as FileWrapping, wrap
	- support alternate representations, extract sub resources as needed
	*/
	
	public func child(named:String, changedNameTo:String) {
		//TODO: write me
		//move to the new
		
		
		
	}
	
	
	public func read(from url:URL) throws {
		let aWrapper = try FileWrapper(url: url, options: [])
		if !aWrapper.isDirectory {
			//TODO: throw
			return
		}
		wrapper = aWrapper
	}
	
	//overwriting is implied
	public func write(to url:URL) throws {
		try wrapper.write(to: url, options: [], originalContentsURL: nil)
	}
	
}

extension FileWrapping : ImplementedWithFileWrapper {
	
}

extension DirectoryWrapping : ImplementedWithFileWrapper {
	
}

