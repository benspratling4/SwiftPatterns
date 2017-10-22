//
//  DirectoryMonitor.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 10/8/16.
//  Copyright © 2016 benspratling.com. All rights reserved.
//

import Foundation


#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)

// figure out how to call "open" in Swift 3
import Darwin
	
public class DirectoryMonitor {
	
	public let directoryURL:URL
	private let handler:()->()
	private let queue:DispatchQueue
	private let source:DispatchSourceFileSystemObject
	//private let fileHandle
	
	
	
	private init(queue:DispatchQueue, source:DispatchSourceFileSystemObject, directoryURL:URL, handler:@escaping ()->()) {
		self.queue = queue
		self.source = source
		self.directoryURL = directoryURL
		self.handler = handler
		
		source.setEventHandler { [weak self] in
			self?.directoryDidChange()
		}
		source.setCancelHandler {
			close(source.handle)
		}
		source.resume()
	}
	
	///The handler will be called when files are created, renamed, or deleted.
	public convenience init?(directoryURL:URL, handler:@escaping ()->()) {
		//TODO: determine if it exists?  or does opening the file fail if it does not exist?
		guard let fileDescriptor:Int32 = directoryURL.withUnsafeFileSystemRepresentation({ (systemFileName) -> (Int32?) in
			guard let systemFileName = systemFileName else { return nil }
			//Swift can't figure out which function to call if I just call it, but by providing the signature directly, it can
			let openFunc:(UnsafePointer<CChar>,Int32) -> Int32 = open
			return openFunc(systemFileName, O_EVTONLY)
		}) else { return nil }
		let queue = DispatchQueue(label: "DirectoryMonitor \(directoryURL.path)", attributes: [])
		let source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: queue)
		self.init(queue:queue, source:source, directoryURL:directoryURL, handler:handler)
	}
	
	private func directoryDidChange() {
		handler()
	}
	
	deinit {
		source.cancel()
		//TODO: do I need to close the file?
	}
	
}
	
#endif
