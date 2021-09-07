//
//  Array+StableUniqueValues.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 3/15/20.
//  Copyright © 2020 Sing Accord LLC. All rights reserved.
//

import Foundation

extension Array where Element : Hashable {
	
	public mutating func appendIfNotContained(_ newElement:Element) {
		if !contains(newElement) {
			append(newElement)
		}
	}
}
