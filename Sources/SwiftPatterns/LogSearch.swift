//
//  LogSearch.swift
//  SiftPatterns
//
//  Created by Ben Spratling on 9/4/16.
//  Copyright © 2016 benspratling.com. All rights reserved.
//

import Foundation

/**
	A logarithmic search (LogSearch) finds an argument to a monotonic function.  It does so in O(log inRange.count)-time, and is thus useful for functions which are expensive to evaluate.

	You provide a search range and a closure to evaluate your function, while LogSearch finds the best step in the range, based on responses from the evaluator

	The `matching` argument tweaks the algorithm to find exact matches, find the minimum step over some limit, or the largest step under some limit.

	Your evaluator closure does not return the function value.  Instead it determines whether the step supplied to it resulted in an exact match, is over a matching step value, or under a matching step value.

	If you can predict the step at which the match should occur, return .predict() from the evaluator.  LogSearch will infer whether the current step was .under or .over depending on whether the step given in .predict() is higher or lower.  Don't worry about returning a prediction out of bounds, it will be clamped to the known valid range.  Even a poor approximation of the inverse of your function can help dramatically, as long as the local slope is correct.

	In general, merely initialize the search object, then immediately pull the result, like this:

	let searchResult:Int? = LogSearch(inRange: 0...100, matching: .min, evaluator:{ (step) -> (LogSearch.Evaluation) in
		return step < 37 ? .under : .over
	}).resolvedStep

	This will find "37" since it is a .min search, and any value under 37 is reported as .under, while 37 or a larger value is reported as .over

	LogSearch is designed to return nil after exceeding inRange.count number of iteration.  This both prevents run-away execution, and also means accidental non-monotonic functions will be rejected.
*/
public class LogSearch {
	
	public enum Matching {
		/// the log search can and must find the exact value; if no iteration of evaluator returns .exact, .resolvedStep will be nil
		case exact
		
		/// Find the smallest step which is not .under
		case min
		
		/// Find the largest step which is not .over
		case max
	}
	
	public enum Evaluation : Equatable {
		/// the function exactly matches the desired value at this step
		case exact
		
		/// the step is lower than a matching value
		case under
		
		/// the step is larger than a matching value
		case over
		
		/// Predicts the step value for a match.  Consider this not a match, and to be under or over depending on which direction the next step is
		case predict(step:Int)
	}
	
	private let range:CountableClosedRange<Int>
	
	private let matching:Matching
	
	/// the step at which the
	public var resolvedStep:Int?
	
	/// diagnosing performance
	public var iterationSteps:[Int] = []
	
	/// O(log inRange.count)
	public init(inRange:CountableClosedRange<Int>, matching:Matching = .exact, evaluator:(_ step:Int)->(Evaluation)) {
		range = inRange
		self.matching = matching
		//don't store the evaluator, since merely passing it along means it is not-escaping
		resolvedStep = allSearch(evaluator: evaluator)
	}
	
	//inRange should have a count greater than 1
	private func nextStep(inRange:CountableClosedRange<Int>, predictedStep:Int?)->Int {
		//if predictedStep is in the predicted range
		if let predicted:Int = predictedStep {
			if inRange.contains(predicted) {
				return predicted
			} else {
				//clamp it
				if predicted < inRange.lowerBound {
					return inRange.lowerBound
				} else {
					// predicted < inRange.upperBound
					return inRange.upperBound
				}
			}
		} else {
			//just return the middle of the remaining range
			switch matching {
			case .exact, .min:
				return (inRange.upperBound - inRange.lowerBound)/2 + inRange.lowerBound
			case .max:
				//since integer division rounds down, we can end up in a spot where there is a 2-part range and we never evaluate the upper value.  So I cheat by adding 1 to the sum before dividing, which makes it round up
				return (inRange.upperBound - inRange.lowerBound + 1)/2 + inRange.lowerBound
			}
		}
	}
	
	///constants (per matching) to add to the bounds when affected by the results of the prediction
	private var boundsAdjustments:(lowerChange:Int, upperChange:Int) {
		switch matching {
		case .exact:
			return (1,-1)
		case .max:
			return (0,-1)
		case .min:
			return (1,0)
		}
	}
	
	private func allSearch(evaluator:(_ step:Int)->(Evaluation))->Int? {
		//the range of values which would be "ok" to return
		var okRange:CountableClosedRange<Int> = range
		
		// if the evaluator returned a predicted step, it is stored here for the next iteration
		var predictedStep:Int?
		
		//.exact - the value just evaluated needs to be kept out of range if it's not exact.
		//.min or max the evaluated value can remain in the range as long as its on the correct end
		let (lowerChange, upperChange):(Int, Int) = boundsAdjustments
		
		//succesively narrow the range to values which could be the answer
		while okRange.count > 1 {
			//prevent run-away evaluation
			if iterationSteps.count > range.count + 1 {
				return nil
			}
			
			//find the mid of the range and evaluate then either change the bottom or top of the range
			let targetStep:Int = nextStep(inRange: okRange, predictedStep: predictedStep)
			predictedStep = nil
			
			//keep track of each step for performance evaluation
			iterationSteps.append(targetStep)
			
			//call the iterator
			switch evaluator(targetStep) {
				//adjust the range based on the evaluation
			case .exact:
				return targetStep
			case let .predict(step: nextStep) where nextStep < targetStep:
				predictedStep = nextStep
				fallthrough
			case .over:
				okRange = okRange.lowerBound ... (targetStep + upperChange)
			case let .predict(step: nextStep) where nextStep >= targetStep:
				predictedStep = nextStep
				fallthrough
			case .under:
				okRange = (targetStep+lowerChange) ... okRange.upperBound
			default:
				break	//compiler does not know it's already exhaustive
			}
		}
		
		//the final step, there's only one value left to evaluate
		switch (matching, evaluator(okRange.upperBound)) {
		case (_, .exact):
			return okRange.upperBound
		case (.exact, _):
			return nil
		case (.min, .under):
			return nil
		case (.min, let .predict(step: nextStep)) where nextStep > okRange.upperBound:
			return nil
		case (.min, _):
			return okRange.upperBound
		case (.max, .over):
			return nil
		case (.max, let .predict(step: nextStep)) where nextStep < okRange.lowerBound:
			return nil
		case (.max, _):
			return okRange.upperBound
		}
	}
}


public func ==(lhs:LogSearch.Evaluation, rhs:LogSearch.Evaluation)->Bool {
	switch (lhs, rhs) {
	case (.exact, .exact):
		return true
	case (.under, .under):
		return true
	case (.over, .over):
		return true
	case (.predict(let lhsStep), .predict(let rhsStep)):
		return lhsStep == rhsStep
	default:
		return false
	}
}
