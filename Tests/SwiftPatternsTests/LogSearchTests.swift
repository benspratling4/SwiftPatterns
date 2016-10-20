//
//  LogSearchTests.swift
//  LogSearchTests
//
//  Created by Ben Spratling on 9/4/16.
//  Copyright © 2016 benspratling.com. All rights reserved.
//

import XCTest
import SwiftPatterns

class LogSearchTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testExactMatches() {
		for limit:Int in [10,100,1000] {
			for target in 0...limit {
				let searchResult:Int? = LogSearch(inRange: 0...limit, matching: .exact, evaluator:{ (step) -> (LogSearch.Evaluation) in
					if step == target {
						return .exact
					} else if step < target {
						return .under
					} else {
						return .over
					}
				}).resolvedStep
				XCTAssertEqual(target, searchResult)
			}
		}
	}
	
	
	func testMinMatches() {
		for limit:Int in [10,100,1000] {
			for target in 0...limit {
				let searchResult:Int? = LogSearch(inRange: 0...limit, matching: .min, evaluator:{ (step) -> (LogSearch.Evaluation) in
					if step < target {
						return .under
					} else {
						return .over
					}
				}).resolvedStep
				XCTAssertEqual(target, searchResult)
			}
		}
	}
	
	func testMaxMatches() {
		for limit:Int in [10,100,1000] {
			for target in 1...limit {
				let searchResult:Int? = LogSearch(inRange: 0...limit, matching: .max, evaluator:{ (step) -> (LogSearch.Evaluation) in
					if step < target {
						return .under
					} else {
						return .over
					}
				}).resolvedStep
				XCTAssertEqual(target-1, searchResult )
			}
		}
	}
	
	/*
	func testPrediction() {
		
		//given a function, predict the next value based on a
		
		
		
		
		
		
		
		
	}
	*/
	
    
}
