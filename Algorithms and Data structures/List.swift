//
//  List.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 17.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public protocol List : ExpressibleByArrayLiteral {
	
	init()
	
	var array : [Element] { get set }
	
	// stack-related
	mutating func pushBack(_: Element)	// O(n)
	mutating func popBack() -> Element?	// O(n)
	
	// array-related
	mutating func insert(_: Element, at: Int) throws	// O(n)
	mutating func remove(at: Int) throws -> Element		// O(n)
	subscript(index: Int) -> Element? { get set }		// O(n)
}

public enum ListError : Error {
	case IndexOutOfRange
}

