//
//  String+fixes.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 6/6/18.
//  Copyright © 2018 benspratling.com. All rights reserved.
//

import Foundation


extension String {
	
	///if the string has the prefix, returns the rest of the string, otherwise returns nil
	public func withoutPrefix(_ prefix:String)->String? {
		guard let range = self.range(of: prefix, options: [.anchored]) else { return nil }
		return String(self[range.upperBound..<self.endIndex])
	}
	
	///if the string has the suffix, returns the rest of the string, otherwise returns nil
	public func withoutSuffix(_ suffix:String)->String? {
		guard let range = self.range(of: suffix, options: [.anchored, .backwards]) else { return nil }
		return String(self[self.startIndex..<range.lowerBound])
	}
	
}
