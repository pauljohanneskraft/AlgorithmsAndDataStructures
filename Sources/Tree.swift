//
//  Tree.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation


public protocol Tree : PriorityQueue {
	var array : [Element] { get }
}

public extension Tree where Element : Comparable {
	init() { self.init { $0 < $1 } }
	
	init(arrayLiteral: Element...) throws {
		self.init()
		for e in arrayLiteral { try self.push(e) }
	}
}

protocol _BinTree : Tree {
	associatedtype Node : _BinTreeNode
	var root : Node? { get set }
}

protocol _BinTreeNode {
	associatedtype Element
	var data	: Element	{ get }
	var right	: Self?		{ get set }
	var left	: Self?		{ get set }
	
	init(data: Element, order: @escaping (Element, Element) -> Bool)
	
	mutating func push(_: Element) throws
	
	var array : [Element] { get }
}






