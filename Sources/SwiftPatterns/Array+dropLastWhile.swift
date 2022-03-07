//
//  Array+dropLastWhile.swift.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 3/6/22.
//

import Foundation

extension Array {
	///returns an array slice which is missing the items off the end for which the predicate returns true
	///so the last element in the returned slice will be the first element from the end for which predicate returns false
	///If the predicate returns true for all elements, returns []
	public func dropLast(while predicate: (Element) throws -> Bool) rethrows -> ArraySlice<Element> {
		for i in 0..<self.count {
			if !(try predicate(self[self.count - i - 1])) {
				return self[0..<self.count - i]
			}
		}
		return self[0..<0]
	}
}
