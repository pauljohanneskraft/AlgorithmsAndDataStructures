//
//  Tree.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public protocol Tree: PriorityQueue {
	var array: [Element] { get }
}

public extension Tree where Element: Comparable {
	init() { self.init { $0 < $1 } }
}

protocol BinaryTreeProtocol: Tree {
	associatedtype Node: BinaryTreeNodeProtocol
	var root: Node? { get set }
}

protocol BinaryTreeNodeProtocol {
	associatedtype Element
	var data: Element { get }
    var order: (Element, Element) -> Bool { get }
	
	init(data: Element, order: @escaping (Element, Element) -> Bool)
		
	var array: [Element] { get }
}
