import Foundation

public struct ChangeSet {
	public var inserted:Set<Int>
	public var removed:Set<Int>
	public var refreshed:Set<Int>
	public var moved:[Int:Int]
	
	public init(inserted:Set<Int> = [], removed:Set<Int> = [], refreshed:Set<Int> = [], moved:[Int:Int] = [:]) {
		self.inserted = inserted
		self.removed = removed
		self.refreshed = refreshed
		self.moved = moved
	}
}

extension ChangeSet : Equatable {
}


extension Set {
	public static func make(_ range:CountableRange<Int>)->Set<Int> {
		var values:[Int] = []
		for i in range {
			values.append(i)
		}
		return Set<Int>(values)
	}
}


public func == (lhs:ChangeSet, rhs:ChangeSet)->Bool {
	if lhs.inserted != rhs.inserted { return false }
	if lhs.removed != rhs.removed { return false }
	if lhs.refreshed != rhs.refreshed { return false }
	if lhs.moved != rhs.moved { return false }
	return true
}


extension Array where Element : Hashable {
	
	/// Assuming elements in the arrays are unique, this provides a change set from two arrays
	public func changeSet(from originalArray:Array<Element>)->ChangeSet {
		//indexes in the originalArray of strings which are not present in self
		var removedIndexes:Set<Int> = []
		
		//indexes of strings in self which are not present in originalArray
		var insertedIndexes:Set<Int> = []
		
		//make quick look up of the indexes from originalArray
		var oldIndexes:[Element:Int] = [:]
		for (index, value) in originalArray.enumerated() {
			oldIndexes[value] = index
		}
		
		//1) make the list of new indexes, and go ahead and mark strings with no corresponding old index as inserted
		var newIndexes:[Element:Int] = [:]
		for (index, value) in self.enumerated() {
			newIndexes[value] = index
			//we've already built the original index, might as well check if these have been replaced.
			if oldIndexes[value] == nil {
				insertedIndexes.insert(index)
			}
		}
		
		//get a list of removed indexes, which we know if they aren't in newIndexes
		for (index, value) in originalArray.enumerated() {
			if newIndexes[value] == nil {
				removedIndexes.insert(index)
			}
		}
		
		//now we only have to find the re-orders.
		//.... which are defined as the objects in the new array, which aren't where the additions and subtractions say they would be
		var oldIndex:Int = 0
		var newIndex:Int = 0
		var exhaustedOld:Bool = false
		var exhaustedNew:Bool = false
		
		//keys are original index number, values are new index number
		var movedMap:[Int:Int] = [:]
		
		//keys are new index #, values are old number
		var reverseMoveMap:[Int:Int] = [:]
		
		while true {
			if oldIndex == originalArray.count {
				exhaustedOld = true
				break
			}
			
			if newIndex == count {
				exhaustedNew = true
				break
			}
			
			//if we're at a removed index, advance the old pointer and continue
			if removedIndexes.contains(oldIndex) {
				oldIndex += 1
				continue
			}
			
			//if we inserted this index, advance the new pointer and continue
			if insertedIndexes.contains(newIndex) {
				newIndex += 1
				continue
			}
			
			//if these values are not equal, we re-ordered something
			let oldValue:Element = originalArray[oldIndex]
			let newValue:Element = self[newIndex]
			
			if newValue == oldValue {
				newIndex += 1
				oldIndex += 1
				continue
			}
			
			//if they are not equal, it was reordered somewhere
			//check if we already knew this new string was moved in place (we'll run into all moves twice)
			if reverseMoveMap[newIndex] != nil {
				newIndex += 1
				continue
			}
			
			//figure out where we moved this string
			let newPosition:Int = newIndexes[oldValue]!
			movedMap[oldIndex] = newPosition
			reverseMoveMap[newPosition] = oldIndex
			
			oldIndex += 1
		}
		
		return ChangeSet(inserted:insertedIndexes, removed:removedIndexes, moved:movedMap)
	}
	
}


extension Array where Element : AnyObject {
	
	/// Assuming elements in the arrays are unique, this provides a change set from two arrays
	public func changeSet(from originalArray:Array<Element>)->ChangeSet {
		let originalWrapper:[ObjectIdentifier] = originalArray.map({ObjectIdentifier($0)})
		let wrappedSelf:[ObjectIdentifier] = self.map({ObjectIdentifier($0)})
		return wrappedSelf.changeSet(from: originalWrapper)
	}
	
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIKit
	
	
	extension IndexPath {
		static func paths(withRows:Set<Int>, section:Int)->[IndexPath] {
			var paths:[IndexPath] = []
			for row in withRows {
				paths.append(IndexPath(row: row, section: section))
			}
			return paths
		}
	}
	
	
	extension UITableView {
		public func apply(changeSet:ChangeSet, section:Int = 0) {
			beginUpdates()
			if !changeSet.removed.isEmpty {
				let deletedPaths:[IndexPath] = IndexPath.paths(withRows:changeSet.removed, section:section)
				deleteRows(at: deletedPaths, with: .automatic)
			}
			if !changeSet.inserted.isEmpty {
				let insertedPaths:[IndexPath] = IndexPath.paths(withRows:changeSet.inserted, section: section)
				insertRows(at: insertedPaths, with: .automatic)
			}
			if !changeSet.refreshed.isEmpty {
				let refreshedPaths:[IndexPath] = IndexPath.paths(withRows:changeSet.refreshed, section: section)
				reloadRows(at: refreshedPaths, with: .automatic)
			}
			if !changeSet.moved.isEmpty {
				for (old, new) in changeSet.moved {
					let oldPath:IndexPath = IndexPath(row: old, section: section)
					let newPath:IndexPath = IndexPath(row: new, section: section)
					moveRow(at: oldPath, to: newPath)
				}
			}
			endUpdates()
		}
		
	}
	
	//TODO: collection view
	
	extension UICollectionView {
		public func apply(changeSet:ChangeSet, section:Int = 0) {
			//TODO: use completion block?
			performBatchUpdates({
				if !changeSet.removed.isEmpty {
					let deletedPaths:[IndexPath] = IndexPath.paths(withRows: changeSet.removed, section: section)
					self.deleteItems(at: deletedPaths)
				}
				if !changeSet.inserted.isEmpty {
					let insertedPaths:[IndexPath] = IndexPath.paths(withRows: changeSet.inserted, section: section)
					self.insertItems(at: insertedPaths)
				}
				if !changeSet.refreshed.isEmpty {
					let refreshedPaths:[IndexPath] = IndexPath.paths(withRows: changeSet.refreshed, section: section)
					self.reloadItems(at: refreshedPaths)
				}
				if !changeSet.moved .isEmpty {
					for (old, new) in changeSet.moved {
						let oldPath:IndexPath = IndexPath(item: old, section: section)
						let newPath:IndexPath = IndexPath(item: new, section: section)
						self.moveItem(at: oldPath, to: newPath)
					}
				}
				}, completion: nil)
		}
	}
	
	
#elseif os(macOS)
	import Cocoa
	
	//TODO: write me


extension NSTableView {
	public func apply(changeSet:ChangeSet) {
		beginUpdates()
		if !changeSet.removed.isEmpty {
			removeRows(at: IndexSet(Array<Int>(changeSet.removed)), withAnimation: [.slideUp])
		}
		if !changeSet.inserted.isEmpty {
			insertRows(at: IndexSet(Array<Int>(changeSet.inserted)), withAnimation: [.slideDown])
		}
		if !changeSet.refreshed.isEmpty {
			reloadData(forRowIndexes: IndexSet(Array<Int>(changeSet.refreshed)), columnIndexes: IndexSet(integersIn: 0..<self.numberOfColumns))
		}
		if !changeSet.moved.isEmpty {
			for (old, new) in changeSet.moved {
				moveRow(at: old, to: new)
			}
		}
		endUpdates()
	}
}

extension IndexPath {
	static func paths(withRows:Set<Int>, section:Int)->[IndexPath] {
		var paths:[IndexPath] = []
		for row in withRows {
			paths.append(IndexPath(item: row, section: section))
		}
		return paths
	}
}

extension NSCollectionView {
	
	@available(macOS 10.11, *)
	public func apply(changeSet:ChangeSet, section:Int = 0) {
		performBatchUpdates({
			if !changeSet.removed.isEmpty {
				let deletedPaths:Set<IndexPath> = Set<IndexPath>(IndexPath.paths(withRows: changeSet.removed, section: section))
				self.deleteItems(at: deletedPaths)
			}
			if !changeSet.inserted.isEmpty {
				let insertedPaths:Set<IndexPath> = Set<IndexPath>(IndexPath.paths(withRows: changeSet.inserted, section: section))
				self.insertItems(at: insertedPaths)
			}
			if !changeSet.refreshed.isEmpty {
				let refreshedPaths:Set<IndexPath> = Set<IndexPath>(IndexPath.paths(withRows: changeSet.refreshed, section: section))
				self.reloadItems(at: refreshedPaths)
			}
			if !changeSet.moved .isEmpty {
				for (old, new) in changeSet.moved {
					let oldPath:IndexPath = IndexPath(item: old, section: section)
					let newPath:IndexPath = IndexPath(item: new, section: section)
					self.moveItem(at: oldPath, to: newPath)
				}
			}
		}, completionHandler: nil)
	}
	
}

	
#endif

