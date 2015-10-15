//
//  ViewController.swift
//  RecyclingCenterExample
//
//  Created by Christopher Luu on 10/14/15.
//  Copyright © 2015 Nuudles. All rights reserved.
//

import UIKit
import RecyclingCenter

class ViewController: UIViewController
{
	// MARK: - Private constants
	private static let redReuseIdentifier = "redReuseIdentifier"
	private static let blueReuseIdentifier = "blueReuseIdentifier"

	// MARK: - Private properties
	private var redViews: [RecyclableView] = []
	private var blueViews: [RecyclableView] = []
	private lazy var recyclingCenter: RecyclingCenter<RecyclableView> =
	{
		let recyclingCenter = RecyclingCenter<RecyclableView>()
		recyclingCenter.registerInitHandler({ (_) in NSLog("Creating red"); return RecyclableView(color: .redColor()) }, forReuseIdentifier: ViewController.redReuseIdentifier)
		recyclingCenter.registerInitHandler({ (_) in NSLog("Creating blue"); return RecyclableView(color: .blueColor()) }, forReuseIdentifier: ViewController.blueReuseIdentifier)
		return recyclingCenter
	}()

	// MARK: - View methods
	override func viewDidLoad()
	{
		super.viewDidLoad()

		navigationItem.rightBarButtonItems = [
			UIBarButtonItem(title: "+Red", style: .Plain, target: self, action: Selector("addRed")),
			UIBarButtonItem(title: "-Red", style: .Plain, target: self, action: Selector("deleteRed")),
			UIBarButtonItem(title: "+Blue", style: .Plain, target: self, action: Selector("addBlue")),
			UIBarButtonItem(title: "-Blue", style: .Plain, target: self, action: Selector("deleteBlue"))
		]
	}

	// MARK: - Button action methods
	func addRed()
	{
		let redView = recyclingCenter.dequeueObjectWithReuseIdentifier(ViewController.redReuseIdentifier, context: nil)
		redViews.append(redView)

		redView.center = CGPoint(x: CGFloat(arc4random_uniform(UInt32(view.bounds.size.width))), y: CGFloat(arc4random_uniform(UInt32(view.bounds.size.height))))
		view.addSubview(redView)
	}

	func addBlue()
	{
		let blueView = recyclingCenter.dequeueObjectWithReuseIdentifier(ViewController.blueReuseIdentifier, context: nil)
		blueViews.append(blueView)

		blueView.center = CGPoint(x: CGFloat(arc4random_uniform(UInt32(view.bounds.size.width))), y: CGFloat(arc4random_uniform(UInt32(view.bounds.size.height))))
		view.addSubview(blueView)
	}

	func deleteRed()
	{
		guard redViews.count > 0 else { return }

		let redView = redViews.removeFirst()
		redView.removeFromSuperview()
		recyclingCenter.enqueueObject(redView, withReuseIdentifier: ViewController.redReuseIdentifier)
	}

	func deleteBlue()
	{
		guard blueViews.count > 0 else { return }

		let blueView = blueViews.removeFirst()
		blueView.removeFromSuperview()
		recyclingCenter.enqueueObject(blueView, withReuseIdentifier: ViewController.blueReuseIdentifier)
	}
}

class RecyclableView: UIView, Recyclable
{
	// MARK: - Init methods
	init(color: UIColor)
	{
		super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

		backgroundColor = color
	}

	required init?(coder aDecoder: NSCoder)
	{
		fatalError("This init method should never be called")
	}
}
