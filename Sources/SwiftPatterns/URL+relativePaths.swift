//
//  URL+relativePaths.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 3/6/19.
//  Copyright © 2019 benspratling.com. All rights reserved.
//

import Foundation

extension URL {
	
	///Assuming parentUrl contains
	public func pathComponentsRelative(to parentUrl:URL)->[String]? {
		let parentComponents:[String] = parentUrl.pathComponents
		let childComponents:[String] = pathComponents
		if childComponents.count < parentComponents.count {
			return nil
		}
		for (index, childComponent) in parentComponents.enumerated() {
			if parentComponents[index] != childComponent {
				return nil
			}
		}
		return [String](childComponents.suffix(from: parentComponents.count))
	}
	
	public func isSubPath(of url:URL)->Bool {
		let parentComponents:[String] = url.pathComponents
		let childComponents:[String] = pathComponents
		if childComponents.count < parentComponents.count {
			return false
		}
		for (index, childComponent) in parentComponents.enumerated() {
			if parentComponents[index] != childComponents[index] {
				return false
			}
		}
		return true
	}
	
}

