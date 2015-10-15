# RecyclingCenter

`RecyclingCenter` is a simple manager that handles dequeuing and enqueuing reused objects. It works similar to how `UITableView` and `UICollectionView` dequeue their cells. Instead of registering a class, you register an `initHandler` closure, which returns your `Recyclable` class.

## Features

- Simply dequeue and enqueue your `Recyclable` objects
- Clears out the unused objects when the application receives a memory warning
- Works with any kind of object, not just UI elements

## Requirements

- iOS 8.0+
- tvOS 9.0+
- Xcode 7+

## Installation using CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

Because `RecyclingCenter ` is written in Swift, you must use frameworks.

To integrate `RecyclingCenter ` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'RecyclingCenter'
```

Then, run the following command:

```bash
$ pod install
```

## Usage

You will need to have a `RecyclingCenter` for each kind of `Recyclable` class you want to use. Simply initialize a center and register an `initHandler` for your `reuseIdentifier`:

```swift
let recyclingCenter = RecyclingCenter<RecyclableView>()
recyclingCenter.registerInitHandler({ (_) in return RecyclableView(color: .redColor()) }, forReuseIdentifier: ViewController.redReuseIdentifier)
```

Later when you want to dequeue a `Recyclable` object by calling:

```swift
let redView = recyclingCenter.dequeueObjectWithReuseIdentifier(ViewController.redReuseIdentifier, context: nil)
```

When you want to recycle a view, simply enqueue it:

```swift
recyclingCenter.enqueueObject(redView, withReuseIdentifier: ViewController.redReuseIdentifier)
```

Take a look at the Example project for a more concrete example. Try playing around with the `+Red` and `+Blue` buttons and you should see logs when the `RecyclingCenter` has to create the objects. Remove them using the `-Red` and `-Blue` buttons and when you re-add new views you should see that the views are being recycled. If you simulate a memory warning, you should see the recycled objects get flushed out, thus having to create new ones.