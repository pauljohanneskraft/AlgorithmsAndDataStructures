//
//  CompositeBinaryTree.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct CompositeBinaryTree<Element: Equatable>: Tree {
    public func contains(_ data: Element) -> Bool {
        return root.contains(data)
    }
    
    public mutating func insert(_ data: Element) throws {
        try push(data)
    }
    
    public mutating func remove(_ data: Element) throws {
        root = try root.remove(data)
    }
    
    public mutating func removeAll() {
        root = Leaf(order: order)
    }
    
    public var count: UInt {
        return root.count
    }
    
    public typealias DataElement = Element
    
    var root: Node
    
    public init(order: @escaping (Element, Element) -> Bool) {
        self.root = Leaf(order: order)
    }
    
    public var array: [Element] {
        get {
            return root.array
        }
        set {
            root = Leaf(order: order)
            newValue.forEach { try? insert($0) }
        }
    }
    
    public var order: (Element, Element) -> Bool {
        return root.order
    }
    
    public mutating func push(_ data: Element) throws {
        root = try root.push(data)
    }
    
    public mutating func pop() -> Element? {
        let ret = root.pop()
        self.root = ret.node
        return ret.data
    }
    
    class Node {
        let order: (Element, Element) -> Bool
        var count: UInt {
            return 0
        }
        
        init(order: @escaping (Element, Element) -> Bool) {
            self.order = order
        }
        
        var array: [Element] { return [] }
        
        func push(_ data: Element) throws -> Node {
            return InnerNode(data: data, order: order)
        }
        
        func remove(_ data: Element) throws {
            throw DataStructureError.notIn
        }
        
        func pop() -> (data: Element?, node: Node) {
            return (nil, self)
        }
        
        func remove(_ data: Element) throws -> Node {
            throw DataStructureError.notIn
        }
        
        func contains(_ data: Element) -> Bool {
            return false
        }
        
        func removeLast() -> (data: Element?, node: Node) {
            return (nil, self)
        }
    }
    
    final class InnerNode: Node, BinaryTreeNodeProtocol {
        var left: Node
        var right: Node
        var data: Element
        
        init(data: Element, order: @escaping (Element, Element) -> Bool) {
            self.data = data
            self.left = Leaf(order: order)
            self.right = Leaf(order: order)
            super.init(order: order)
        }
        
        override var array: [Element] {
            return left.array + [data] + right.array
        }
        
        override func push(_ newData: Element) throws -> Node {
            guard data != newData else {
                throw DataStructureError.alreadyIn
            }
            if order(newData, data) {
                left = try left.push(newData)
            } else {
                right = try right.push(newData)
            }
            return self
        }
        
        override func remove(_ data: Element) throws -> Node {
            if data == self.data {
                let leftPop = left.removeLast()
                left = leftPop.node
                if let data = leftPop.data {
                    self.data = data
                    return self
                }
                return right
            } else if order(data, self.data) {
                left = try left.remove(data)
            } else {
                right = try right.remove(data)
            }
            return self
        }
        
        override func removeLast() -> (data: Element?, node: CompositeBinaryTree.Node) {
            let remLast = right.removeLast()
            right = remLast.node
            guard let element = remLast.data else {
                return (self.data, left)
            }
            return (element, self)
        }
        
        override func pop() -> (data: Element?, node: Node) {
            if left is Leaf {
                return (self.data, right)
            }
            let (data, newLeft) = left.pop()
            left = newLeft
            return (data, self)
        }
        
        override func contains(_ data: Element) -> Bool {
            if data == self.data {
                return true
            } else if order(data, self.data) {
                return left.contains(data)
            } else {
                return right.contains(data)
            }
        }
        
        override var count: UInt {
            return left.count + right.count + 1
        }
    }
    
    final class Leaf: Node {
        
    }
}
