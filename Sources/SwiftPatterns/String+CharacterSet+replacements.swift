//
//  String+CharacterSet+replacements.swift
//  
//
//  Created by Ben Spratling on 4/9/22.
//

import Foundation

extension String {
	
	///characters in the given set are replaced with the given string
	public mutating func replaceCharacters(from set:CharacterSet, with string:String) {
		var targetIndex = endIndex
		while targetIndex > startIndex {
			guard let range = rangeOfCharacter(from: set, options: [.backwards], range: startIndex..<targetIndex) else { break }
			replaceSubrange(range, with: string)
			targetIndex = range.lowerBound
		}
	}
	
	///same as above, but can be used on let
	public func replacingCharacters(from set:CharacterSet, with string:String)->String {
		var newString = self
		newString.replaceCharacters(from: set, with: string)
		return newString
	}
	
	///removes characters in self that are in the set with
	public mutating func deleteCharacters(from set:CharacterSet) {
		self.replaceCharacters(from: set, with: "")
	}
	
	///returns a string that is self, but with any characters in the given set removed
	public func deletingCharacters(from set:CharacterSet)->String {
		var newString = self
		newString.deleteCharacters(from: set)
		return newString
	}
	
}
