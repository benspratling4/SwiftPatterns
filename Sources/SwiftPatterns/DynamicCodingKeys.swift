//
//  DynamicCodingKeys.swift
//  SingMusicData
//
//  Created by Ben Spratling on 3/31/18.
//  Copyright © 2018 benspratling.com. All rights reserved.
//

import Foundation


public struct DynamicCodingKeys : CodingKey {
	
	public var stringValue: String
	
	public init?(stringValue: String) {
		self.stringValue = stringValue
		intValue = nil
	}
	
	
	public var intValue: Int?
	
	public init?(intValue: Int) {
		self.intValue = intValue
		stringValue = "\(intValue)"
	}
}
