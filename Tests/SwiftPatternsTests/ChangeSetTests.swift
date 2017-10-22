//
//  ChangeSetTests.swift
//  SwiftPatterns
//
//  Created by Ben Spratling on 10/8/16.
//  Copyright © 2016 benspratling.com. All rights reserved.
//

import XCTest
import SwiftPatterns


class ChangeSetTests: XCTestCase {

	class ChangeSetTestClass {
	}
	
	func testEmptyHashableArrays() {
		let empty0:[String] = []
		let empty1:[String] = []
		let changeSet = empty0.changeSet(from:empty1)
		XCTAssertEqual(changeSet, ChangeSet())
	}
	
	func testEmptyClassArrays() {
		let empty0:[ChangeSetTestClass] = []
		let empty1:[ChangeSetTestClass] = []
		let changeSet = empty0.changeSet(from:empty1)
		XCTAssertEqual(changeSet, ChangeSet())
	}
	
	
	func testIdenticalClassArrays() {
		let empty0:[ChangeSetTestClass] = [ChangeSetTestClass(), ChangeSetTestClass(), ChangeSetTestClass()]
		let empty1:[ChangeSetTestClass] = empty0
		let changeSet = empty0.changeSet(from:empty1)
		XCTAssertEqual(changeSet, ChangeSet())
	}
	
	func testInsert1ClassArrays() {
		let empty0:[ChangeSetTestClass] = [ChangeSetTestClass(), ChangeSetTestClass(), ChangeSetTestClass()]
		var empty1:[ChangeSetTestClass] = empty0
		empty1.insert(ChangeSetTestClass(), at: 1)
		let changeSet = empty1.changeSet(from:empty0)
		XCTAssertEqual(changeSet, ChangeSet(inserted:[1]))
	}
	
	
	func testInsert3ClassArrays() {
		let empty0:[ChangeSetTestClass] = [ChangeSetTestClass(), ChangeSetTestClass(), ChangeSetTestClass()]
		var empty1:[ChangeSetTestClass] = empty0
		empty1.insert(ChangeSetTestClass(), at: 1)
		empty1.insert(ChangeSetTestClass(), at: 3)
		let changeSet = empty1.changeSet(from:empty0)
		XCTAssertEqual(changeSet, ChangeSet(inserted:[1,3]))
	}
	
	func testInsertedAndRemovedClassArrays() {
		let empty0:[ChangeSetTestClass] = [ChangeSetTestClass(), ChangeSetTestClass(), ChangeSetTestClass()]
		var empty1:[ChangeSetTestClass] = empty0
		empty1.remove(at: 1)
		empty1.insert(ChangeSetTestClass(), at: 1)
		empty1.insert(ChangeSetTestClass(), at: 3)
		let changeSet = empty1.changeSet(from:empty0)
		XCTAssertEqual(changeSet, ChangeSet(inserted:[1,3], removed:[1]))
	}
	
	
	func testInsertedAndRemovedAndMovedClassArrays() {
		let empty0:[ChangeSetTestClass] = [ChangeSetTestClass(), ChangeSetTestClass(), ChangeSetTestClass()]
		var empty1:[ChangeSetTestClass] = empty0
		empty1.remove(at: 1)
		empty1.insert(ChangeSetTestClass(), at: 1)
		empty1.insert(ChangeSetTestClass(), at: 3)
		empty1.append(empty1[0])
		empty1.remove(at: 0)
		let changeSet = empty1.changeSet(from:empty0)
		XCTAssertEqual(changeSet, ChangeSet(inserted:[0,2], removed:[1], moved:[0:3]))
	}
	
	
	static var allTests = [
		("testEmptyHashableArrays",testEmptyHashableArrays),
		("testEmptyClassArrays",testEmptyClassArrays),
		("testIdenticalClassArrays",testIdenticalClassArrays),
		("testInsert1ClassArrays",testInsert1ClassArrays),
		("testInsert3ClassArrays",testInsert3ClassArrays),
		("testInsertedAndRemovedClassArrays",testInsertedAndRemovedClassArrays),
		("testInsertedAndRemovedClassArrays",testInsertedAndRemovedClassArrays),
		("testInsertedAndRemovedAndMovedClassArrays",testInsertedAndRemovedAndMovedClassArrays),
	]

}
