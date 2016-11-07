//
//  List.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 17.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public protocol List : ExpressibleByArrayLiteral, CustomStringConvertible {
	init()
	
	var count : Int { get }
	
	var array : [Element] { get set }
	
	// stack-related
	mutating func pushBack(_: Element)	// O(n)
	mutating func popBack() -> Element?	// O(n)
	
	// array-related
	mutating func insert(_: Element, at: Int) throws	// O(n)
	mutating func remove(at: Int) throws -> Element		// O(n)
	subscript(index: Int) -> Element? { get set }		// O(n)
}

internal protocol _List : List {
	associatedtype Node : _ListItem
	var root : Node? { get set }
}

internal protocol _ListItem : CustomStringConvertible {
	associatedtype Element
	
	init(data: Element)
	
	var data : Element { get }
	var next : Self? { get set }
	
	var count : Int { get }
	
	var array : [Element] { get }
	
	// stack-related
	mutating func pushBack(_: Element)	// O(n)
}

extension _ListItem {
	
	var count : Int { return next != nil ? next!.count + 1 : 1 }
	
	var array: [Element] {
		let result = next?.array
		return [data] + (result != nil ? result! : [])
	}
	
	mutating func popBack() -> Element {
		assert(next != nil, "No following node found.")
		if next!.next == nil {
			let tmp = next!.data
			next = nil
			return tmp
		} else { return next!.popBack() }
	}
}


public enum ListError : Error {
	case IndexOutOfRange
}

