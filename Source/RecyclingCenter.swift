//
//  RecyclingCenter.swift
//  RecyclingCenter
//
//  Created by Christopher Luu on 10/14/15.
//  Copyright © 2015 Nuudles. All rights reserved.
//

import Foundation

public protocol Recyclable: Hashable
{
	
}

public class RecyclingCenter<T: Recyclable>
{
	public typealias RecyclableType = T

	// MARK: - Private properties
	private var initHandlers: [String: (context: Any?) -> (RecyclableType)] = [:]
	private var unusedRecyclables: [String: Set<RecyclableType>] = [:]

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
	public func registerInitHandler(initHandler: (context: Any?) -> (RecyclableType), forReuseIdentifier reuseIdentifier: String)
	{
		initHandlers[reuseIdentifier] = initHandler
		unusedRecyclables[reuseIdentifier] = Set<RecyclableType>()
	}

	public func deregisterInitHandlerForReuseIdentifier(reuseIdentifier: String)
	{
		initHandlers[reuseIdentifier] = nil
		unusedRecyclables[reuseIdentifier] = nil
	}

	public func dequeueObjectWithReuseIdentifier(reuseIdentifier: String, context: Any?) -> RecyclableType
	{
		guard unusedRecyclables[reuseIdentifier] != nil else { fatalError("Unknown reuseIdentifier: \(reuseIdentifier)") }
		if let object = unusedRecyclables[reuseIdentifier]!.popFirst()
		{
			return object
		}

		guard let initHandler = initHandlers[reuseIdentifier] else { fatalError("Could not find initHandler for reuseIdentifier: \(reuseIdentifier)") }
		let object = initHandler(context: context)
		return object
	}

	public func enqueueObject(object: RecyclableType, withReuseIdentifier reuseIdentifier: String)
	{
		guard unusedRecyclables[reuseIdentifier] != nil else { fatalError("Unknown reuseIdentifier: \(reuseIdentifier)") }
		unusedRecyclables[reuseIdentifier]!.insert(object)
	}
}
