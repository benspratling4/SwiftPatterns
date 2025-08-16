//
//  String+insertWithPrecautionaryWhitespace.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 3/23/25.
//


import Foundation




extension String {
	/**
	 Replaces the given range of characters with the string, inserting precautionary whitespace if needed.
	 Returns the new index where the insertion cursor would be at the end of the inserted text.
	 */
	@discardableResult
	public mutating func replaceWithPrecautionaryWhitespace(_ string: String, at range: Range<String.Index>)->String.Index {
		let rangeStartOffset = distance(from: startIndex, to: range.lowerBound)
		let rangeCount = string.count
		let (needsLeadingWhitespace, needsTrailingWhitespace) = self.needsPrecautionaryWhitespace(string, at: range)
		
		var stringToInsert = string
		if needsLeadingWhitespace {
			stringToInsert = " " + stringToInsert
		}
		
		if needsTrailingWhitespace {
			stringToInsert += " "
		}
		
		replaceSubrange(range, with: stringToInsert)
		return index(startIndex, offsetBy: rangeStartOffset + rangeCount + (needsLeadingWhitespace ? 1 : 0) + (needsTrailingWhitespace ? 1 : 0))
	}
	
	public func replacingWithPrecautionaryWhitespace(_ string: String, at range: Range<String.Index>)->(String, String.Index) {
		var newSelf = self
		let insertionIndex = newSelf.replaceWithPrecautionaryWhitespace(string, at: range)
		return (newSelf, insertionIndex)
	}
}


#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
extension NSMutableString {
	
	@discardableResult
	public func replaceWithPrecautionaryWhitespace(_ string: String, at range: NSRange)->Int {
		let (needsLeadingWhitespace, needsTrailingWhitespace) = self.needsPrecautionaryWhitespace(string, at: range)
		
		var stringToInsert = string
		if needsLeadingWhitespace {
			stringToInsert = " " + stringToInsert
		}
		
		if needsTrailingWhitespace {
			stringToInsert += " "
		}
		
		replaceCharacters(in: range, with: stringToInsert)
		let newLength = NSString(string: string).length
		return range.location + newLength + (needsLeadingWhitespace ? 1 : 0) + (needsTrailingWhitespace ? 1 : 0)
	}
	
}


extension NSMutableAttributedString {
	
	@discardableResult
	public func replaceWithPrecautionaryWhitespace(_ string: NSAttributedString, at range: NSRange)->Int  {
		let (needsLeadingWhitespace, needsTrailingWhitespace) = mutableString.needsPrecautionaryWhitespace(string.string, at: range)
		let stringToInsert = string.mutableCopy() as! NSMutableAttributedString
		
		var defaultAttributes:[NSAttributedString.Key : Any]?
		if range.location < self.length {
			defaultAttributes = self.attributes(at: range.location, effectiveRange: nil)
		}
		else if range.location > 0 {
			defaultAttributes = self.attributes(at: range.location - 1, effectiveRange: nil)
		}
		
		if needsLeadingWhitespace {
			var attributes:[NSAttributedString.Key : Any]?
			if stringToInsert.length > 0 {
				attributes = stringToInsert.attributes(at: 0, effectiveRange: nil)
			}
			stringToInsert.insert(NSAttributedString(string: " ", attributes: attributes ?? defaultAttributes ?? [:]), at: 0)
		}
		if needsTrailingWhitespace {
			var attributes:[NSAttributedString.Key : Any]?
			if stringToInsert.length > 0 {
				attributes = stringToInsert.attributes(at: stringToInsert.length-1, effectiveRange: nil)
			}
			stringToInsert.insert(NSAttributedString(string: " ", attributes: attributes ?? defaultAttributes ?? [:]), at: stringToInsert.length)
		}
		
		replaceCharacters(in: range, with: stringToInsert)
		return range.location + string.length + (needsLeadingWhitespace ? 1 : 0) + (needsTrailingWhitespace ? 1 : 0)
	}
	
}


extension NSString {
	
	public func needsPrecautionaryWhitespace(_ string: String, at range: NSRange) -> (leading:Bool, trailing:Bool) {
		let selfString = self as String
		guard let insertionRange = Range<String.Index>(range, in:selfString) else {
			//doesn't happen as long as range was valid in self
			return (true, true)
		}
		return selfString.needsPrecautionaryWhitespace(string, at: insertionRange)
	}
	
	public func replacingWithPrecautionaryWhitespace(_ string: String, at range: NSRange)->(NSString, Int) {
		let mutableString = NSMutableString(string: self)
		let newIndex = mutableString.replaceWithPrecautionaryWhitespace(string, at: range)
		return (mutableString, newIndex)
	}
	
}

#endif


extension String {
	
	public func needsPrecautionaryWhitespace(_ string: String, at range: Range<String.Index>) -> (leading:Bool, trailing:Bool) {
		//TODO: detect languages which do not use whitespace and skip
		
		let hostHasPreviousCharacters:Bool = range.lowerBound > startIndex
		let originalHasLeadingWhitespace:Bool
		let originalHasLeadingPunctuation:Bool
		if hostHasPreviousCharacters {
			originalHasLeadingWhitespace = has(characterSet:.whitespacesAndNewlines, before: range.lowerBound)
			originalHasLeadingPunctuation = has(characterSet: .punctuationCharacters, before: range.lowerBound)
		}
		else {
			originalHasLeadingWhitespace = false
			originalHasLeadingPunctuation = false
		}
		
		let hostHasAdditionalCharacters:Bool = range.upperBound < endIndex
		let originalHasTrailingWhitespace:Bool
		let originalHasTrailingPunctuation:Bool
		if hostHasAdditionalCharacters {
			originalHasTrailingWhitespace = has(characterSet: .whitespacesAndNewlines, after: range.upperBound)
			originalHasTrailingPunctuation = has(characterSet: .punctuationCharacters, after: range.upperBound)
		}
		else {
			originalHasTrailingWhitespace = false
			originalHasTrailingPunctuation = false
		}
		
		let inserterHasLeadingWhitespace:Bool = string.rangeOfCharacter(from: .whitespacesAndNewlines, options: .anchored) != nil
		let inserterHasLeadingPunctuation:Bool = string.rangeOfCharacter(from: .punctuationCharacters, options: .anchored) != nil
		let inserterHasTrailingWhitespace:Bool = string.rangeOfCharacter(from: .whitespacesAndNewlines, options: [.anchored, .backwards]) != nil
		let inserterHasTrailingPunctuation:Bool = string.rangeOfCharacter(from: .punctuationCharacters, options: [.anchored, .backwards]) != nil
		
		return (
			hostHasPreviousCharacters && (
				(!originalHasLeadingWhitespace && !inserterHasLeadingWhitespace)
				&& !( !originalHasLeadingWhitespace && inserterHasLeadingPunctuation && !originalHasLeadingPunctuation)
				
			)
			,hostHasAdditionalCharacters && (
				!originalHasTrailingWhitespace && !inserterHasTrailingWhitespace
				&& !(!inserterHasTrailingWhitespace && originalHasTrailingPunctuation && !inserterHasTrailingPunctuation)
			)
		)
		
	}
	
	public func has(characterSet:CharacterSet, before index:String.Index)->Bool {
		rangeOfCharacter(
			from: characterSet
			, options: [.anchored, .backwards]
			, range: startIndex..<index)
		!= nil
	}
	
	public func has(characterSet:CharacterSet, after index:String.Index)->Bool {
		rangeOfCharacter(
			from:characterSet
			,options: [.anchored]
			,range: index..<endIndex
			) != nil
	}
	
}
