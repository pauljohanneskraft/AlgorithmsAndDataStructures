//
//  BinaryTree.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct BinaryTree<Element: Equatable> {
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

extension BinaryTree: BinaryTreeProtocol, Tree {
    public func contains(_ data: Element) -> Bool {
        return root?.contains(data) ?? false
    }
    
    public mutating func insert(_ data: Element) throws {
        try push(data)
    }
    
    public mutating func remove(_ data: Element) throws {
        guard let res = try root?.remove(data) else {
            throw DataStructureError.notIn
        }
        root = res
    }
    
    public mutating func removeAll() {
        root = nil
    }
    
    public var count: UInt {
        return root?.count ?? 0
    }
    
    public typealias DataElement = Element
    
    public var array: [Element] {
        get {
            return root?.array ?? []
        }
        set {
            removeAll()
            newValue.forEach { try? insert($0) }
            
        }
    }
    
    public mutating func push(_ data: Element) throws {
        guard let root = root else {
            self.root = Node(data: data, order: order)
            return
        }
        try root.push(data)
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
    func push(_ newData: Element) throws {
        guard newData != data else {
            throw DataStructureError.alreadyIn
        }
        let newDataIsSmaller = order(newData, data)
        guard let node = newDataIsSmaller ? left: right else {
            if newDataIsSmaller {
                self.left = BinaryTree.Node(data: newData, order: order)
            } else {
                self.right = BinaryTree.Node(data: newData, order: order)
            }
            return
        }
        try node.push(newData)
    }
    
    func contains(_ data: Element) -> Bool {
        if self.data == data {
            return true
        } else if order(data, self.data) {
            return left?.contains(data) ?? false
        } else {
            return right?.contains(data) ?? true
        }
    }
    
    func removeLast() -> (data: Element, node: BinaryTree.Node?) {
        if let rightNode = right {
            let result = rightNode.removeLast()
            right = result.node
            return (result.data, self)
        }
        return (data: data, node: left)
    }
    
    func remove(_ data: Element) throws -> BinaryTree.Node? {
        if data == self.data {
            if let last = left?.removeLast() {
                left = last.node
                self.data = last.data
                return self
            } else {
                return right
            }
        } else if order(data, self.data) {
            left = try left?.remove(data)
        } else {
            right = try right?.remove(data)
        }
        return self
    }
    
    var count: UInt {
        return (left?.count ?? 0) + (right?.count ?? 0) + 1
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
