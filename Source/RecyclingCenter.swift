//
//  RecyclingCenter.swift
//  RecyclingCenter
//
//  Created by Christopher Luu on 10/14/15.
//  Copyright © 2015 Nuudles. All rights reserved.
//

import UIKit

/// A protocol that describes items which can be recycled in the `RecyclingCenter`
public protocol Recyclable: Hashable
{
	
}

public enum RecyclingCenterError: ErrorType
{
	case UnknownReuseIdentifier(reuseIdentifier: String)
	case NoInitHandlerForReuseIdentifier(reuseIdentifier: String)
}

/// `RecyclingCenter` is a simple manager that handles dequeuing and enqueuing reused objects.
/// It works similar to how `UITableView` and `UICollectionView` dequeue their cells.
/// Instead of registering a class, you register an `initHandler` closure, which returns an instance of your `Recyclable` class.
///
public class RecyclingCenter<T: Recyclable>
{
	public typealias RecyclableType = T

	// MARK: - Internal properties
	/// A dictionary of `initHandler`s keyed by their respective `reuseIdentifier`s
	internal var initHandlers: [String: (context: Any?) -> (RecyclableType)] = [:]
	/// A dictionary of a set of `Recyclable` objects that are ready to be reused keyed by their respective `reuseIdentifier`s
	internal var unusedRecyclables: [String: Set<RecyclableType>] = [:]

	// MARK: - Init methods
	public init()
	{
		NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidReceiveMemoryWarningNotification, object: nil, queue: nil)
		{
			[unowned self]
			(_) in
			for key in self.unusedRecyclables.keys
			{
				self.unusedRecyclables[key]!.removeAll()
			}
		}
	}

	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	// MARK: - Public methods
	/// Registers a closure that instantiates a `Recyclable` object based on an optional `context` for a specific `reuseIdentifier`
	///
	/// - parameter initHandler: The closure, which takes in an optional `context` and returns an instantiated `Recyclable` object
	/// - parameter reuseIdentifier: The `reuseIdentifier` with which to associate the `initHandler`
	///
	public func registerInitHandler(initHandler: (context: Any?) -> (RecyclableType), forReuseIdentifier reuseIdentifier: String)
	{
		initHandlers[reuseIdentifier] = initHandler
		unusedRecyclables[reuseIdentifier] = Set<RecyclableType>()
	}

	/// Deregisters an `initHandler` closure for the given `reuseIdentifier`
	///
	/// - parameter reuseIdentifier: The `reuseIdentifier` whose `initHandler` should be deregistered
	///
	public func deregisterInitHandlerForReuseIdentifier(reuseIdentifier: String)
	{
		initHandlers[reuseIdentifier] = nil
		unusedRecyclables[reuseIdentifier] = nil
	}

	/// Dequeues a `Recyclable` object with a given `reuseIdentifier` and `context`.
	/// This method will return a recycled object if one is available, otherwise it uses the `initHandler` closure associated with
	/// the `reuseIdentifier` to instantiate a new `Recyclable` object based on the provided `context`
	///
	/// - parameter reuseIdentifier: The `reuseIdentifier` to dequeue
	/// - parameter context: An optional `context` that can be provided to the `initHandler`
	/// - returns: An instantiated `Recyclable` based on the `reuseIdentifier` and `context`
	///
	public func dequeueObjectWithReuseIdentifier(reuseIdentifier: String, context: Any? = nil) throws -> RecyclableType
	{
		guard unusedRecyclables[reuseIdentifier] != nil else { throw RecyclingCenterError.UnknownReuseIdentifier(reuseIdentifier: reuseIdentifier) }
		if let object = unusedRecyclables[reuseIdentifier]!.popFirst()
		{
			return object
		}

		guard let initHandler = initHandlers[reuseIdentifier] else { throw RecyclingCenterError.NoInitHandlerForReuseIdentifier(reuseIdentifier: reuseIdentifier
			) }
		let object = initHandler(context: context)
		return object
	}

	/// Enqueue a `Recyclable` object for later reuse
	///
	/// - parameter object: The `Recyclable` object that should be enqueued
	/// - parameter reuseIdentifier: The `reuseIdentifier` to enqueue the object with
	///
	public func enqueueObject(object: RecyclableType, withReuseIdentifier reuseIdentifier: String) throws
	{
		guard unusedRecyclables[reuseIdentifier] != nil else { throw RecyclingCenterError.UnknownReuseIdentifier(reuseIdentifier: reuseIdentifier) }
		unusedRecyclables[reuseIdentifier]!.insert(object)
	}
}
