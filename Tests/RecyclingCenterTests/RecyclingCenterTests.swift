//
//  RecyclingCenterTests.swift
//  RecyclingCenterTests
//
//  Created by Noah Blake on 11/24/15.
//
//

import XCTest
@testable import RecyclingCenter

// MARK: - Reuse identifiers -
enum ReuseIdentifier: String {
	case Glass
	case Paper
	case Plastic
	case Unknown
}
// MARK: - <Recyclable> -
public class RecyclableMaterial: Recyclable {
	public var hashValue: Int {	return identifier.hashValue }
	var identifier: String { return ReuseIdentifier.Unknown.rawValue }
}
public func ==(lhs: RecyclableMaterial, rhs: RecyclableMaterial) -> Bool {
	return lhs.hashValue == rhs.hashValue
}
public class Glass: RecyclableMaterial {
	override var identifier: String { return ReuseIdentifier.Glass.rawValue }
}
public class Paper: RecyclableMaterial {
	override var identifier: String { return ReuseIdentifier.Paper.rawValue }
}
public class Plastic: RecyclableMaterial {
	override var identifier: String { return ReuseIdentifier.Plastic.rawValue }
}
// MARK: - Tests -
class RecyclingCenterTests: XCTestCase {
	/// The central testing component.
	var testRecyclingCenter: RecyclingCenter<RecyclableMaterial>!
    // MARK: - Registration - 
	/// A registered initHandler should be added to the initHandler dictionary, and a set of the recycled type should
	/// be created.
	override func setUp() {
		super.setUp()
		testRecyclingCenter = RecyclingCenter<RecyclableMaterial>()
	}
	func testRegistration() {
		let input = Glass()
		testRecyclingCenter.registerInitHandler({ (context: Any?) -> RecyclableMaterial in
			return input
			}, forReuseIdentifier: input.identifier)
		let handler = testRecyclingCenter.initHandlers[input.identifier]
		let set = testRecyclingCenter.unusedRecyclables[input.identifier]
		XCTAssert(handler != nil && set as? Set<Glass> != nil)
	}
	/// When multiple handlers are registered, they should be stored by their corresponding identifier.
	func testMultipleRegistration() {
		let input = [Glass(), Paper(), Plastic()]
		for material in input {
			testRecyclingCenter.registerInitHandler({ (context: Any?) -> RecyclableMaterial in
				return material
				}, forReuseIdentifier: material.identifier)
		}
		XCTAssert(testRecyclingCenter.initHandlers.count == input.count && testRecyclingCenter.unusedRecyclables.count == input.count)
	}
	/// Duplicating a registration should not lead to duplications in the underlying data structure.
	func testDuplicateRegistration() {
		let input = Glass()
		
		for _ in 0...3 {
			testRecyclingCenter.registerInitHandler({ (context: Any?) -> RecyclableMaterial in
			return input
			}, forReuseIdentifier: input.identifier)
		}
		XCTAssert(testRecyclingCenter.initHandlers.count == 1 && testRecyclingCenter.unusedRecyclables.count == 1)
	}
	// MARK: - Deregistration - 
	/// Once an initHandler is derigestered, it should not longer appear in the initHandler dictionary, and its type
	/// should be removed from the unusedRecyclables dictionary.
	func testDeregistration() {
		let input = Glass()
		testRecyclingCenter.registerInitHandler({ (context: Any?) -> RecyclableMaterial in
			return input
			}, forReuseIdentifier: input.identifier)
		testRecyclingCenter.deregisterInitHandlerForReuseIdentifier(input.identifier)
		XCTAssert(testRecyclingCenter.initHandlers.isEmpty && testRecyclingCenter.unusedRecyclables.isEmpty)
	}
	// MARK: - Enqueue -
	/// Enqueue should add an object to the unusedRecyclables for the given reuse identifier.
	func testEnqueue() {
		let input = Glass()
		testRecyclingCenter.registerInitHandler({ (context: Any?) -> RecyclableMaterial in
			return input
			}, forReuseIdentifier: input.identifier)
		testRecyclingCenter.enqueueObject(input, withReuseIdentifier: input.identifier)
		XCTAssert(testRecyclingCenter.unusedRecyclables[input.identifier]?.popFirst() == input)
	}
	/// Enqueue
	/// An object must be registered for a reuse identifier before it is enqueued.
	/// TODO: Complete this test by declaring the possibility of an exception in `enqueueObject(_:,_:)`
	func testPrematureEnqueueFailure() {
//		let input = Glass()
//		testRecyclingCenter.enqueueObject(input, withReuseIdentifier: input.identifier)
		XCTFail()
	}
	// MARK: - Dequeue -
	/// A registered initHandler should initialize an object on dequeue.
	func testInitHandlerDequeue() {
		let input = Glass()
		testRecyclingCenter.registerInitHandler({ (context: Any?) -> RecyclableMaterial in
			return input
			}, forReuseIdentifier: input.identifier)
		let output = testRecyclingCenter.dequeueObjectWithReuseIdentifier(input.identifier)
		XCTAssert(input == output)
	}
	// A registered initHandler should initialize objects based on the dequeue context.
	func testInitHandlerContextualDequeue() {
		let identifier = "SINGLE_STREAM", glassContext = "GLASS_CONTEXT", plasticContext = "PLASTIC_CONTEXT"
		testRecyclingCenter.registerInitHandler({ (context: Any?) -> RecyclableMaterial in
			if (context as? String) == glassContext {
				return Glass()
			} else if (context as? String) == plasticContext {
				return Plastic()
			} else {
				return Paper()
			}
			}, forReuseIdentifier: identifier)
		let glass = testRecyclingCenter.dequeueObjectWithReuseIdentifier(identifier, context: glassContext)
		let plastic = testRecyclingCenter.dequeueObjectWithReuseIdentifier(identifier, context: plasticContext)
		XCTAssert(glass as? Glass != nil && plastic as? Plastic != nil)
	}
	/// An object initialized through a registered initHandler should be repeatedly dequeueable.
	func testInitHandlerRepeatedDequeue() {
		let input = Glass()
		testRecyclingCenter.registerInitHandler({ (context: Any?) -> RecyclableMaterial in
			return input
			}, forReuseIdentifier: input.identifier)
		let results = [
			testRecyclingCenter.dequeueObjectWithReuseIdentifier(input.identifier),
			testRecyclingCenter.dequeueObjectWithReuseIdentifier(input.identifier),
			testRecyclingCenter.dequeueObjectWithReuseIdentifier(input.identifier)
		]
		for object in results {
			XCTAssert(input == object)
		}
	}
	/// An initHandler must be registered for a reuse identifier before an object may be dequeued.
	/// TODO: Complete this test by declaring the possibility of an exception in `dequeueObjectWithReuseIdentifier(_:,_:)`
	func testPrematureDInitHandlerDequeueFailure() {
//		let material = testRecyclingCenter.dequeueObjectWithReuseIdentifier(ReuseIdentifier.Unknown.rawValue)
		XCTFail()
	}
    /// An enqueued object should be dequeueable.
	func testEnqueuedObjectDequeue() {
		let input = Glass()
		let initHandlerResponse = Plastic()
		testRecyclingCenter.registerInitHandler({ (context: Any?) -> RecyclableMaterial in
			return initHandlerResponse
			}, forReuseIdentifier: input.identifier)
		testRecyclingCenter.enqueueObject(input, withReuseIdentifier: input.identifier)
		let result = testRecyclingCenter.dequeueObjectWithReuseIdentifier(input.identifier)
		XCTAssert(input == result)
	}
	/// An enqueued object should be repeatedly dequeueable.
	func testEnqueuedObjectBeDequeuedOnce() {
		let input = Glass()
		let initHandlerResponse = Plastic()
		testRecyclingCenter.registerInitHandler({ (context: Any?) -> RecyclableMaterial in
			return initHandlerResponse
			}, forReuseIdentifier: input.identifier)
		testRecyclingCenter.enqueueObject(input, withReuseIdentifier: input.identifier)
		let results = [
			testRecyclingCenter.dequeueObjectWithReuseIdentifier(input.identifier),
			testRecyclingCenter.dequeueObjectWithReuseIdentifier(input.identifier),
			testRecyclingCenter.dequeueObjectWithReuseIdentifier(input.identifier)
		]
		let expectations = [
			input,
			initHandlerResponse,
			initHandlerResponse
		]
		for (result, expectation) in zip(results, expectations) {
			XCTAssert(result == expectation)
		}
		
	}
}
