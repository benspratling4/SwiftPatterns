//
//  Math.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 10/8/16.
//  Copyright © 2016 benspratling.com. All rights reserved.
//

import Swift

import Foundation

extension FloatingPoint {
	public static var π:Self {
		return Self.pi
	}
}

infix operator ≤ : ComparisonPrecedence

infix operator ≥ : ComparisonPrecedence

infix operator ≠ : ComparisonPrecedence

public func ≤<T:Comparable>(left:T, right:T)->Bool {
	return left <= right
}

public func ≥<T:Comparable>(left:T, right:T)->Bool {
	return left >= right
}

public func ≠<T:Equatable>(left:T, right:T)->Bool {
	return left != right
}

precedencegroup ExponentialPrecedence {
	associativity: left
	higherThan: MultiplicationPrecedence
}

/*
prefix operator √ : ExponentialPrecedence	//Why doesn't this compile?

extension FloatingPoint {
	public static prefix func √(left:Self)->Self {
		return sqrt(left)
	}
}
*/

infix operator ^ : ExponentialPrecedence

extension Float32 {
	public static func ^(left:Float32, right:Float32)->Float32 {
		return pow(left, right)
	}
}

extension Float64 {
	public static func ^(left:Float64, right:Float64)->Float64 {
		return pow(left, right)
	}
}

/*
extension Float80 {
//why is there no pow for Float80 ?
	public static func ^(left:Float80, right:Float80)->Float80 {
		return pow(left, right)
	}
}
*/
