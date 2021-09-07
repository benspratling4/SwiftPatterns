//
//  LocalFileSource.swift
//  SingMusic
//
//  Created by Ben Spratling on 8/12/16.
//
//

import Foundation


public protocol FileSource {
	
	var urls:[URL] { get }
	
}

open class LocalFileSource : FileSource {
	
	open var urls:[URL] = []
	
	fileprivate var changeHandler:(_ changes:ChangeSet)->()
	fileprivate let directoryURL:URL
	fileprivate let extensions:Set<String>
	fileprivate var directoryMonitor:DirectoryMonitor?
	
	public init?(directoryURL:URL, extensions:[String] = [], handler:@escaping (_ changes:ChangeSet)->()) {
		if !directoryURL.isFileURL { return nil }
		if !FileManager.default.fileExists(atPath: directoryURL.path) { return nil }
		
		self.extensions = Set<String>(extensions)
		self.changeHandler = handler
		self.directoryURL = directoryURL
		directoryMonitor = DirectoryMonitor(directoryURL: directoryURL, handler: { [weak self] in
			self?.directoryDidChange()
		})
		updateURLs()
	}
	
	fileprivate func directoryDidChange() {
		updateURLs()
	}
	
	fileprivate func updateURLs() {
		let oldPaths:[String] = urls.map { (aURL) -> String in
			return aURL.path
		}.sorted()
		let newURLs:[URL] = matchingURLs()
		let newPaths:[String] = newURLs.map { (aURL) -> String in
			return aURL.path
		}.sorted()
		urls = newURLs
		changeHandler(newPaths.changeSet(from:oldPaths))
	}
	
	fileprivate func matchingURLs()->[URL] {
		let fileManager:FileManager = FileManager.default
		guard let contents = try? fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]) else { return [] }
		return contents.filter({ (aURL) -> Bool in
			return extensions.contains(aURL.pathExtension)
		})
	}
	
}
