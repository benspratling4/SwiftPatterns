//
//  QueuedVar.swift
//  SingMusic
//
//  Created by Ben Spratling on 1/27/16.
//
//

import Foundation
import Dispatch

/// Synchronizes access to a model on a concurrent queue
/// Calls to these methods use Dispatch.sync, so do not call recursively
public class QueuedVar<Model> : MediatedAccess {
	
	private let queue:DispatchQueue
	
	private var model:Model
	
	/// If you do not provide a queue, a serial queue will be created for you
	public init(queue:DispatchQueue? = nil, model:Model) {
		self.queue = queue ?? DispatchQueue(label: "", attributes: DispatchQueue.Attributes.concurrent)
		self.model = model
	}
	
	/// All read closures complete before write begins, and then can resume
	public func readWrite<ReturnType>(work:(inout Model) throws ->ReturnType)rethrows->ReturnType {
		return try queue.sync(flags: .barrier, execute: { try work(&self.model) })
	}
	
	/// If you'd like a more convenient access to a value returned from the model.
	open func read<ReturnType>(work:(Model)throws->(ReturnType))rethrows->ReturnType {
		return try queue.sync { ()->ReturnType in try work(self.model) }
	}
	
}
