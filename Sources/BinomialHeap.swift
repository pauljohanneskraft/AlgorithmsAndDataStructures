//
//  BinomialHeap.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct BinomialHeap < Element > : PriorityQueue {
	public private(set) var children : [BinomialTreeNode<Element>]
	public private(set) var minIndex : Int?
	public let order: (Element, Element) -> Bool
	
	public init(order: @escaping (Element, Element) -> Bool) {
		children = []
		minIndex = nil
		self.order = order
	}
	
	mutating func merge(with heads: [BinomialTreeNode<Element>], ignoreMinimum: Bool) {
		guard children.count > 0 else { children = heads; resetMinIndex(); return }
		
		var minimum : BinomialTreeNode<Element>? = nil
		var treesNew = [BinomialTreeNode<Element>]()
		var carry : BinomialTreeNode<Element>? = nil
		var rank = 0
		var treeIndex = 0
		var headsIndex = 0
		while true {
			var a : BinomialTreeNode<Element>? = nil
			var minRank = 0
			
			while treeIndex < children.count {
				let tree = children[treeIndex]
				if ignoreMinimum {
					treeIndex += 1
					continue
				}
				minRank = tree.rank
				if tree.rank == rank {
					a = tree
					treeIndex += 1
				}
				break
			}
			
			var b : BinomialTreeNode<Element>? = nil
			
			if headsIndex < heads.count {
				let tree = heads[headsIndex]
				
				if tree.rank < minRank { minRank = tree.rank }
				if tree.rank == rank {
					b = tree
					headsIndex += 1
				}
			}
			if a == nil && b == nil && carry == nil {
				if treeIndex >= children.count && headsIndex >= heads.count { break }
				else { rank = minRank; continue }
			} else { rank += 1 }
			
			let result = add(a, b, carry: carry)
			let x = result.0
			carry = result.1
			
			if x != nil {
				if minimum == nil || order(x!.element, minimum!.element) {
					minimum = x
				}
				treesNew.append(x!)
			}
		}
		self.children = treesNew;
		// self.minIndex = minimum
		resetMinIndex()
	}
	
	func add(_ a: BinomialTreeNode<Element>?, _ b: BinomialTreeNode<Element>?, carry: BinomialTreeNode<Element>?)
		-> (result: BinomialTreeNode<Element>?, carry: BinomialTreeNode<Element>?) {
			var nodes = [BinomialTreeNode<Element>?](repeating: nil, count: 3)
			var count = 0
			if a != nil {
				nodes[count] = a
				count += 1
			}
			if b != nil {
				nodes[count] = b
				count += 1
			}
			if carry != nil {
				nodes[count] = carry
				count += 1
			}
			if count <= 1 {
				return (nodes[0], nil)
			} else {
				precondition(nodes[0]!.depth == nodes[1]!.depth, "Depths do not match. \(nodes[0]!.depth) != \(nodes[1]!.depth)")
				let c : BinomialTreeNode<Element>? = merge(nodes[0]!, nodes[1]!)
				return (nodes[2], c)
			}
	}
	
	public mutating func push(_ element: Element) {
		merge(with: [BinomialTreeNode(element)], ignoreMinimum: false)
	}
	
	public mutating func pop() -> Element? {
		if let minIndex = self.minIndex {
			let result = children[minIndex].element
			let formerMin = children.remove(at: minIndex)
			
			merge(with: formerMin.children, ignoreMinimum: false)
			
			return result
		} else {
			if children.count == 0 { return nil }
			else {
				resetMinIndex()
				return pop()
			}
		}
	}
	
	func merge(_ a: BinomialTreeNode<Element>, _ b: BinomialTreeNode<Element>) -> BinomialTreeNode<Element> {
		precondition(a.depth == b.depth, "Depths are not equal. \(a.depth) != \(b.depth)")
		var c : BinomialTreeNode<Element>
		if self.order(a.element, b.element) {
			c = a
			c.children.append(b)
		} else {
			c = b
			c.children.append(a)
		}
		return c
	}
	
	mutating func resetMinIndex() {
		guard children.count > 0 else { minIndex = nil; return }
		var minElement = children[0].element
		minIndex = 0
		for i in self.children.indices {
			let currentElement = self.children[i].element
			if order(currentElement, minElement) {
				minIndex = i
				minElement = currentElement
			}
		}
	}
	
}

public extension BinomialHeap where Element : Comparable {
	init() {
		self.init { $0 < $1 }
	}
}

extension BinomialHeap : CustomStringConvertible {
	public var description : String {
		var result = "BinomialHeap:\n"
		for c in children {
			result += c.description(depth: 1)
		}
		return result
	}
}

public struct BinomialTreeNode<Element> {
	var children = [BinomialTreeNode<Element>]()
	var element: Element
	
	init(_ element: Element) {
		self.element = element
	}
	
	internal func description(depth: Int) -> String {
		var result = ""
		for _ in 0..<depth { result += "\t" }
		result += "∟\(element)\n"
		for c in children { result += c.description(depth: depth + 1) }
		return result
	}
	
	var rank : Int { return children.count }
	
	var depth : Int {
		if children.count == 0 { return 1 }
		return children.max(by: { $0.children.count > $1.children.count })!.children.count
	}
	
}
