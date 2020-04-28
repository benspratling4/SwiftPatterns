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
	
	///implement as weak
	var parentResourceWrapper:SubResourceWrapping? { get set }
	
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


#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)

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
	
#else

	
public class FileWrapping : DataWrapping, SynchronizedURLResourceWrapping {
	
	weak public var parentResourceWrapper:SubResourceWrapping?
	
	public var lastPathComponent: String {
		didSet {
			parentResourceWrapper?.child(named: oldValue, changedNameTo: lastPathComponent)
		}
	}
	
	public var contents: Data
	
	public var serializedRepresentation: Data {
		get {
			return contents
		}
		set {
			contents = newValue
		}
	}
	
	public init(data:Data, name:String) {
		self.contents = data
		self.lastPathComponent = name
	}
	
	
	public init(contentsOf url:URL)throws {
		try contents = Data(contentsOf:url)
		lastPathComponent = url.lastPathComponent
	}
	
	public func read(from url:URL) throws {
		contents = try Data(contentsOf: url)
		lastPathComponent = url.lastPathComponent
	}
	
	//overwriting is implied
	public func write(to url:URL) throws {
		try contents.write(to: url, options:[.atomic])
	}
	
}

///you can provide a url without it actually reading
public class LazyFileWrapping : DataWrapping, SynchronizedURLResourceWrapping {
	
	weak public var parentResourceWrapper:SubResourceWrapping?
	
	private var url:URL
	
	private var representation:FileWrapping?
	
	public var isLoaded:Bool {
		return representation != nil
	}
	
	private func loadIfNeeded() {
		if representation != nil {
			return
		}
		representation = try? FileWrapping(contentsOf:url)
	}
	
	public var lastPathComponent: String {
		get {
			return url.lastPathComponent
		}
		set {
			changedSinceRead = false
			let oldComponent = url.lastPathComponent
			url = url.deletingLastPathComponent().appendingPathComponent(newValue)
			parentResourceWrapper?.child(named: oldComponent, changedNameTo: newValue)
		}
	}
	
	private var changedSinceRead:Bool = false
	
	public var contents: Data {
		get {
			if !isLoaded {
				loadIfNeeded()
			}
			return representation?.contents ?? Data()
		}
		set {
			changedSinceRead = false
			representation = FileWrapping(data:contents, name:url.lastPathComponent)
		}
	}
	
	public var serializedRepresentation: Data {
		get {
			return contents
		}
		set {
			contents = newValue
		}
	}
	
	public init(data:Data, name:String) {
		url = URL(fileURLWithPath: name)
		representation = FileWrapping(data:data, name:name)
	}
	
	
	public init(contentsOf url:URL)throws {
		self.url = url
		representation = try FileWrapping(contentsOf:url)
	}
	
	public func read(from url:URL) throws {
		contents = try Data(contentsOf: url)
		lastPathComponent = url.lastPathComponent
	}
	
	//overwriting is implied
	public func write(to url:URL) throws {
		if !changedSinceRead { return }	//skip if we never changed anything
		try contents.write(to: url, options:[.atomic])
	}
	
}



public class DirectoryWrapping : SubResourceWrapping, SynchronizedURLResourceWrapping {
	
	weak public var parentResourceWrapper:SubResourceWrapping?
	
	private var subWrappers:[String:SerializedResourceWrapping] = [:]
	
	public var lastPathComponent: String {
		didSet {
			parentResourceWrapper?.child(named: oldValue, changedNameTo: lastPathComponent)
		}
	}
	
	public init(lastPathComponent: String, subWrappers:[String:SerializedResourceWrapping]) {
		self.lastPathComponent = lastPathComponent
		self.subWrappers = subWrappers
	}
	
	public convenience init(wrappers:[String:SerializedResourceWrapping]) {
		self.init(lastPathComponent:"", subWrappers:wrappers)
	}
	
	public init(url:URL, fileManager:FileManager = FileManager()) {
		lastPathComponent = url.lastPathComponent
		let _ = try? recursiveRead(in: url, fileManager: fileManager)
	}
	
	public var serializedRepresentation:Data {
		get {
			fatalError("no implementation of directory wrapping .serializedRepresentation")
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
		guard var existingValue:SerializedResourceWrapping = subWrappers[key]
			else { return }
		existingValue.parentResourceWrapper = nil
	}
	
	public func child(named:String, changedNameTo newName:String) {
		if named == newName { return }
		subWrappers[newName] = subWrappers[named]
		subWrappers[named] = nil
	}
	
	private func recursiveRead(in url:URL, fileManager:FileManager)throws {
		let files:[URL] = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants])
		subWrappers = [:]
		for file in files {
			var isDir: ObjCBool = false
			let _ = fileManager.fileExists(atPath: file.path, isDirectory: &isDir)
			if isDir {
				let dirWrapper = DirectoryWrapping(url: file, fileManager: fileManager)
				subWrappers[file.lastPathComponent] = dirWrapper
				dirWrapper.parentResourceWrapper = self
			} else {
				if let fileWrapper = try? LazyFileWrapping(contentsOf: file) {
					subWrappers[file.lastPathComponent] = fileWrapper
					fileWrapper.parentResourceWrapper = self
				}
			}
		}
	}
	
	
	public func read(from url:URL) throws {
		let manager = FileManager()
		try recursiveRead(in: url, fileManager: manager)
	}
	
	//overwriting is implied
	public func write(to url:URL) throws {
		try recursiveWrite(to: url, fileManager: FileManager())
	}
	
	
	fileprivate func recursiveWrite(to url:URL, fileManager:FileManager)throws {
		var isDir:ObjCBool = false
		if fileManager.fileExists(atPath: url.path, isDirectory: &isDir) || !isDir {
			try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
		}
		
		for (pathComponent, child) in subWrappers {
			let newUrl:URL = url.appendingPathComponent(pathComponent)
			if let dirChild = child as? DirectoryWrapping {
				try dirChild.recursiveWrite(to: newUrl, fileManager: fileManager)
			} else if let syncableChild = child as? SynchronizedURLResourceWrapping {
				try syncableChild.write(to: newUrl)
			}
		}
	}
	
}
	

#endif

