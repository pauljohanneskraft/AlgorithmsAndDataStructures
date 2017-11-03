//
//  BinomialHeap.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct BinomialHeap<Element>: PriorityQueue {
	public private(set) var children: [Tree]
	public private(set) var minIndex: Int?
	public let order: (Element, Element) -> Bool
	
	public init(order: @escaping (Element, Element) -> Bool) {
		children = []
		minIndex = nil
		self.order = order
	}
    
    public var isEmpty: Bool {
        return children.count <= 0
    }
	
	mutating func merge(with heads: [Tree]) {
		guard children.count > 0 else { children = heads; resetMinIndex(); return }
		
		var treesNew = [Tree]()
		var carry: Tree?
		var rank = 0
		var treeIndex = 0
		var headsIndex = 0
		while true {
			var a: Tree?
			var minRank = 0
			
            while treeIndex < children.count {
                let tree = children[treeIndex]
                minRank = tree.rank
                if tree.rank == rank {
                    a = tree
                    treeIndex += 1
                }
                break
            }
			
			var b: Tree?
			
			if headsIndex < heads.count {
				let tree = heads[headsIndex]
				
				if tree.rank < minRank { minRank = tree.rank }
				if tree.rank == rank {
					b = tree
					headsIndex += 1
				}
			}
			guard a != nil || b != nil || carry != nil else {
				guard treeIndex < children.count || headsIndex < heads.count else {
                    break
                }
                rank = minRank
                continue
			}
            rank += 1
			
			let result = add(a, b, carry: carry)
			let x = result.0
			carry = result.1
			
			if x != nil { treesNew.append(x!) }
		}
		self.children = treesNew
		// self.minIndex = minimum
		resetMinIndex()
	}
	
	func add(_ treeA: Tree?, _ treeB: Tree?, carry: Tree?)
		-> (result: Tree?, carry: Tree?) {
            let nodes = [treeA, treeB, carry].flatMap { $0 }
            
			guard nodes.count > 1 else {
                return (nodes[0], nil)
            }
            
			assertEqual(nodes[0].depth, nodes[1].depth)
            let c = merge(nodes[0], nodes[1])
            let res = nodes.count > 2 ? nodes[2] : nil
            return (res, c)
	}
	
	public mutating func push(_ element: Element) {
		merge(with: [Tree(element)])
	}
	
	public mutating func pop() -> Element? {
		guard children.count > 0 else { return nil }
        assertNotNil(self.minIndex)
        guard let minIndex = minIndex else {
            resetMinIndex()
            return pop()
        }
		let result = children[minIndex].element
		let formerMin = children.remove(at: minIndex)
		
		merge(with: formerMin.children)
		
		return result
	}
	
	func merge(_ treeA: Tree, _ treeB: Tree) -> Tree {
        assertEqual(treeA.depth, treeB.depth)
		var c: Tree
		if self.order(treeA.element, treeB.element) {
			c = treeA
			c.children.append(treeB)
		} else {
			c = treeB
			c.children.append(treeA)
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

public extension BinomialHeap where Element: Comparable {
	init() {
		self.init { $0 < $1 }
	}
}

extension BinomialHeap: CustomStringConvertible {
	public var description: String {
		var result = "BinomialHeap:\n"
		for c in children {
			result += c.description(depth: 1)
		}
		return result
	}
}

extension BinomialHeap {
    public struct Tree {
        var children = [Tree]()
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
        
        var rank: Int { return children.count }
        
        var depth: Int {
            if children.count == 0 { return 1 }
            return children.max(by: { $0.children.count > $1.children.count })!.children.count
        }
        
    }
}
