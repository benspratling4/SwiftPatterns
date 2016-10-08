//
//  NonNilArrayFilter.swift
//  SingMusic
//
//  Created by Ben Spratling on 9/19/16.
//
//

//An implementation detail of .nonNilElements
public protocol OptionalProtocolForNonNilArrayFiltering {
	associatedtype NonNilArrayFilteringWrapped
	//Optional already implements this
	var unsafelyUnwrapped: NonNilArrayFilteringWrapped { get }
	var isNilForArrayFiltering:Bool { get }
}

//An implementation detail of .nonNilElements
extension Optional : OptionalProtocolForNonNilArrayFiltering {
	public typealias NonNilArrayFilteringWrapped = Wrapped
	
	public var isNilForArrayFiltering:Bool { return self == nil }
}

extension Array where Element : OptionalProtocolForNonNilArrayFiltering {
	
	/// For Optional Elements only, this returns a type-safe array of safely unwrapped elements which are not nil
	public var nonNilElements:[Element.NonNilArrayFilteringWrapped] {
		let filtered:Array<Element> = self.filter { (instance) -> Bool in
			return !instance.isNilForArrayFiltering
		}
		//this is only safe because we just filtered out nil instances above
		return filtered.map({ (wrappedInstance) -> Element.NonNilArrayFilteringWrapped in
			return wrappedInstance.unsafelyUnwrapped
		})
	}
}
