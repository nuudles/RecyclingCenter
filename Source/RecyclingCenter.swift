//
//  RecyclingCenter.swift
//  RecyclingCenter
//
//  Created by Christopher Luu on 10/14/15.
//  Copyright © 2015 Nuudles. All rights reserved.
//

import UIKit

/// A protocol that describes items which can be recycled in the `RecyclingCenter`
public protocol Recyclable: Hashable {
	
}

public enum RecyclingCenterError: Error {
	case unknown(reuseIdentifier: String)
	case noInitHandler(reuseIdentifier: String)
}

/// `RecyclingCenter` is a simple manager that handles dequeuing and enqueuing reused objects.
/// It works similar to how `UITableView` and `UICollectionView` dequeue their cells.
/// Instead of registering a class, you register an `initHandler` closure, which returns an instance of your `Recyclable` class.
///
public class RecyclingCenter<T: Recyclable>
{
	public typealias RecyclableType = T

	// MARK: - Private properties
	private var observer: NSObjectProtocol?

	// MARK: - Internal properties
	/// A dictionary of `initHandler`s keyed by their respective `reuseIdentifier`s
	internal var initHandlers: [String: (Any?) -> (RecyclableType)] = [:]
	/// A dictionary of a set of `Recyclable` objects that are ready to be reused keyed by their respective `reuseIdentifier`s
	internal var unusedRecyclables: [String: Set<RecyclableType>] = [:]

	// MARK: - Init methods
	public init() {
		observer = NotificationCenter
			.default
			.addObserver(
				forName: UIApplication.didReceiveMemoryWarningNotification,
				object: nil,
				queue: nil) { [weak self] (_) in
					self?.unusedRecyclables.keys.forEach { (key) in
						self?.unusedRecyclables[key]?.removeAll()
					}
				}
	}

	deinit {
		if let observer = observer {
			NotificationCenter.default.removeObserver(observer)
		}
	}

	// MARK: - Public methods
	/// Registers a closure that instantiates a `Recyclable` object based on an optional `context` for a specific `reuseIdentifier`
	///
	/// - parameter initHandler: The closure, which takes in an optional `context` and returns an instantiated `Recyclable` object
	/// - parameter reuseIdentifier: The `reuseIdentifier` with which to associate the `initHandler`
	///
	public func register(initHandler: @escaping (Any?) -> (RecyclableType), for reuseIdentifier: String) {
		initHandlers[reuseIdentifier] = initHandler
		unusedRecyclables[reuseIdentifier] = Set<RecyclableType>()
	}

	/// Deregisters an `initHandler` closure for the given `reuseIdentifier`
	///
	/// - parameter reuseIdentifier: The `reuseIdentifier` whose `initHandler` should be deregistered
	///
	public func deregisterInitHandler(for reuseIdentifier: String) {
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
	public func dequeueObject(with reuseIdentifier: String, context: Any? = nil) throws -> RecyclableType {
		guard unusedRecyclables[reuseIdentifier] != nil
			else { throw RecyclingCenterError.unknown(reuseIdentifier: reuseIdentifier) }

		if let object = unusedRecyclables[reuseIdentifier]?.popFirst() {
			return object
		}

		guard let initHandler = initHandlers[reuseIdentifier]
				else { throw RecyclingCenterError.noInitHandler(reuseIdentifier: reuseIdentifier) }

		let object = initHandler(context)
		return object
	}

	/// Enqueue a `Recyclable` object for later reuse
	///
	/// - parameter object: The `Recyclable` object that should be enqueued
	/// - parameter reuseIdentifier: The `reuseIdentifier` to enqueue the object with
	///
	public func enqueue(object: RecyclableType, with reuseIdentifier: String) throws {
		guard unusedRecyclables[reuseIdentifier] != nil
			else { throw RecyclingCenterError.unknown(reuseIdentifier: reuseIdentifier) }
		unusedRecyclables[reuseIdentifier]?.insert(object)
	}
}
