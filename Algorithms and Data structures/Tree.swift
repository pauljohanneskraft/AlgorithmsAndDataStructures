//
//  Tree.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation


public protocol BinTree {
	associatedtype Element
	
	init(order : @escaping (Element, Element) -> Bool)
	
	var order : (Element, Element) -> Bool { get }
	
	mutating func insert(_: Element) throws
	
	var array : [Element] { get }
}

public extension BinTree where Element : Comparable {
	init() { self.init(order: { $0 < $1 }) }
	
	init(arrayLiteral: Element...) {
		self.init()
		for e in arrayLiteral { try? self.insert(e) }
	}
}

protocol _BinTree : BinTree {
	associatedtype Node : _BinTreeNode
	var root : Node? { get set }
}

protocol _BinTreeNode {
	associatedtype Element
	var data	: Element	{ get }
	var right	: Self?		{ get set }
	var left	: Self?		{ get set }
	
	init(data: Element, order: @escaping (Element, Element) -> Bool)
	
	mutating func insert(_: Element) throws
	
	var array : [Element] { get }
}






