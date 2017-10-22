//
//  MediatedAccess.swift
//  SingMusic
//
//  Created by Ben Spratling on 1/27/16.
//
//

import Foundation

public protocol MediatedAccess {
	
	associatedtype Model
	
	//func readWrite<ReturnType>(allowDeadLocks:Bool, work:(inout Model)throws->(ReturnType))->ReturnType
	func readWrite<ReturnType>(work:(inout Model)throws->(ReturnType))rethrows->ReturnType
	
	func read<ReturnType>(work:(Model)throws->(ReturnType))rethrows->ReturnType
}
