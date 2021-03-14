//
//  File.swift
//  
//
//  Created by Ben Spratling on 3/13/21.
//

import Foundation

open class WeightedNode<Weight> where Weight : AdditiveArithmetic & Comparable {
	public var weight:Weight
	public init(weight:Weight) {
		self.weight = weight
	}
}

open class LeafWeightedNode<Payload, Weight> : WeightedNode<Weight>, CustomStringConvertible where Weight : AdditiveArithmetic & Comparable  {
	public var payload:Payload
	
	public init(weight:Weight, payload:Payload) {
		self.payload = payload
		super.init(weight:weight)
	}
	
	public var description:String {
		return "\(payload):\(self.weight)"
	}
}

open class BinaryWeightedNode<Weight> : WeightedNode<Weight> where Weight : AdditiveArithmetic & Comparable {
	public var left:WeightedNode<Weight>?
	public var right:WeightedNode<Weight>?
	public init(left:WeightedNode<Weight>?, right:WeightedNode<Weight>?) {
		self.left = left
		self.right = right
		super.init(weight: (left?.weight ?? .zero) + (right?.weight ?? .zero) )
	}
}
