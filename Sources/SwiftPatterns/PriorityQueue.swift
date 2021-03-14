//
//  File.swift
//  
//
//  Created by Ben Spratling on 3/13/21.
//

import Foundation

public class PriorityQueue<Weight> where Weight : AdditiveArithmetic & Comparable {
	
	/// isInPriorityOrder should return true if $0 is more priority than $1
	public init(elements:[WeightedNode<Weight>], isInPriorityOrder:@escaping(Weight, Weight)->Bool = { $0 > $1 }) {
		self.isInPriorityOrder = isInPriorityOrder
		self.sortedElements = elements.sorted(by: { isInPriorityOrder($0.weight, $1.weight) })
	}
	
	public var isEmpty:Bool {
		return sortedElements.isEmpty
	}
	
	public func insert(_ node:WeightedNode<Weight>) {
		//TODO: write me to use a log search & insert
		sortedElements = (sortedElements + [node] ).sorted(by: { isInPriorityOrder($0.weight, $1.weight) })
	}
	
	///removes the node with the most priority
	public func removeFirstPriority()->WeightedNode<Weight>? {
		if sortedElements.isEmpty { return nil }
		return sortedElements.removeFirst()
	}
	
	//TODO: re-write me to use a heap
	private var sortedElements:[WeightedNode<Weight>]
	
	private let isInPriorityOrder:(Weight, Weight)->Bool
	
}
