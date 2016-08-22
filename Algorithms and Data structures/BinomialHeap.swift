//
//  BinomialHeap.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct BinomialHeap<Element : Comparable> {
	public private(set) var children : [BinomialTreeNode<Element>]
	public private(set) var minIndex : Int?
	
	public init() {
		children = []
		minIndex = nil
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
				if ignoreMinimum && tree == children[minIndex!] {
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
			
			let result = BinomialHeap.add(a, b, carry: carry)
			let x = result.0
			carry = result.1
			
			if x != nil {
				if minimum == nil || x!.element < minimum!.element {
					minimum = x
				}
				treesNew.append(x!)
			}
		}
		self.children = treesNew;
		// self.minIndex = minimum
		resetMinIndex()
	}
	
	static func add<E : Comparable>(_ a: BinomialTreeNode<E>?, _ b: BinomialTreeNode<E>?, carry: BinomialTreeNode<E>?)
		-> (result: BinomialTreeNode<E>?, carry: BinomialTreeNode<E>?) {
			var nodes = [BinomialTreeNode<E>?](repeating: nil, count: 3)
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
				assert(nodes[0]!.depth == nodes[1]!.depth)
				let res = nodes[2]
				let n0 = nodes[0]!
				let n1 = nodes[1]!
				let c : BinomialTreeNode<E>? = BinomialTreeNode<E>.merge(n0, n1)
				return (res, c)
			}
			
	}
	
	public mutating func insert(_ element: Element) {
		merge(with: [BinomialTreeNode(element)], ignoreMinimum: false)
	}
	
	public mutating func deleteMin() -> Element? {
		if let minIndex = self.minIndex {
			let result = children[minIndex].element
			let formerMin = children.remove(at: minIndex)
			
			merge(with: formerMin.children, ignoreMinimum: false)
			
			return result
		} else {
			if children.count == 0 { return nil }
			else {
				resetMinIndex()
				return deleteMin()
			}
		}
	}
	
	mutating func resetMinIndex() {
		guard children.count > 0 else { minIndex = nil; return }
		var minElement = children[0].element
		minIndex = 0
		for i in self.children.indices {
			let currentElement = self.children[i].element
			if currentElement < minElement {
				minIndex = i
				minElement = currentElement
			}
		}
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

public struct BinomialTreeNode<Element : Comparable> : Equatable {
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
	
	static func merge<E : Comparable>(_ a: BinomialTreeNode<E>, _ b: BinomialTreeNode<E>) -> BinomialTreeNode<E> {
		assert(a.depth == b.depth)
		var c : BinomialTreeNode<E>
		if a.element < b.element {
			c = a
			c.children.append(b)
		} else {
			c = b
			c.children.append(a)
		}
		return c
	}
	
	var rank : Int {
		return children.count
	}
	
	var depth : Int {
		if children.count == 0 { return 1 }
		return children.max(by: { $0.children.count > $1.children.count })!.children.count
	}
	
}

public func == <E : Comparable>(lhs: BinomialTreeNode<E>, rhs: BinomialTreeNode<E>) -> Bool {
	return lhs.element == rhs.element
}
