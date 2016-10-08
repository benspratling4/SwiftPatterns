//
//  Alert.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 10/8/16.
//  Copyright © 2016 benspratling.com. All rights reserved.
//

/// Use this to represent alerts that need to be presented to the user from non-UI framework
open class Alert {
	open var title:String
	open var description:String
	open let actions:[Action]
	public init(title:String, description:String, actions:[Action]) {
		self.title = title
		self.description = description
		self.actions = actions
	}
	///convenience, because some api's want only
	open var cancelAction:Action? {
		return actions.filter({ (action) -> Bool in
			return action.kind == .cancel
		}).first
	}
	
	open class Action {
		
		public enum Kind {
			case cancel, destructive, normal
		}
		
		open let title:String
		open let action:()->()
		open let kind:Kind
		
		public init(title:String, kind:Kind, action:@escaping ()->()) {
			self.title = title
			self.kind = kind
			self.action = action
		}
	}
	
}

