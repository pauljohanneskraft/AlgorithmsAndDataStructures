//
//  BinaryTree.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct BinaryTree<Element> {
    var root: Node?
    public let order: (Element, Element) -> Bool
    
    public init(order: @escaping (Element, Element) -> Bool) {
        self.order = order
    }
}

extension BinaryTree {
    final class Node {
        var data: Element
        var right: Node?
        var left: Node?
        let order: (Element, Element) -> Bool
        
        required init(data: Element, order: @escaping (Element, Element) -> Bool) {
            self.data  = data
            self.order = order
        }
    }
}

extension BinaryTree: BinaryTreeProtocol {
    public var array: [Element] {
        return root?.array ?? []
    }
    
    public mutating func push(_ data: Element) {
        guard let root = root else {
            self.root = Node(data: data, order: order)
            return
        }
        root.push(data)
    }
    
	public mutating func pop() -> Element? {
		var parent	= root
		var current = root?.left
		
		guard current != nil else {
			let data = root?.data
			root = root?.right
			return data
		}
		
		while current?.left != nil {
			parent	= current
			current	= current?.left
		}
		
		let data = current?.data
		
		parent?.left = current?.right
		
		return data
	}
}

extension BinaryTree: CustomStringConvertible {
	public var description: String {
		let result = "\(BinaryTree<Element>.self)"
		guard let root = root else { return result + " empty." }
		return "\(result)\n" + root.description(depth: 1)
	}
}

extension BinaryTree.Node: BinaryTreeNodeProtocol {
    func push(_ newData: Element) {
        let newDataIsSmaller = order(newData, data)
        guard let node = newDataIsSmaller ? left: right else {
            if newDataIsSmaller {
                self.left = BinaryTree.Node(data: newData, order: order)
            } else {
                self.right = BinaryTree.Node(data: newData, order: order)
            }
            return
        }
        node.push(newData)
    }
    
    var array: [Element] {
        return (left?.array ?? []) + [data] + (right?.array ?? [])
    }
}

extension BinaryTree.Node {
	public func description(depth: UInt) -> String {
		let tab = "   "
		var tabs = tab * depth
		var result = "\(tabs)∟\(data)\n"
		let d: UInt = depth + 1
		tabs += tab
        result += left?.description(depth: d) ?? ""
        result += right?.description(depth: d) ?? ""
		return result
	}
}
