//
//  AVLCompositeBinaryTree.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct AVLCompositeBinaryTree<Element: Equatable>: Tree {
    public func contains(_ data: Element) -> Bool {
        return root.contains(data)
    }
    
    public mutating func remove(_ data: Element) throws {
        root = try root.remove(data)
    }
    
    public mutating func removeAll() {
        root = LeafNode(order: order)
    }
    
    private var root: Node
    public var order: (Element, Element) -> Bool {
        return root.order
    }
    
    public init(order: @escaping (Element, Element) -> Bool) {
        root = LeafNode(order: order)
    }
    
    public mutating func insert(_ newData: Element) throws {
        root = try root.insert(newData)
    }
    
    public mutating func push(_ data: Element) throws {
        try insert(data)
    }
    
    public mutating func pop() -> Element? {
        let result = root.pop()
        root = result.node
        return result.data
    }
    
    public var array: [Element] {
        get {
            return root.array
        }
        set {
            removeAll()
            newValue.forEach { try? insert($0) }
        }
    }
    
    var dotDescription: String {
        return "\tdigraph g { \n\t\tgraph [ordering = out] \n" + root.dotDescription + "\t}\n"
    }
    
    public var count: UInt {
        return root.count
    }
}

extension AVLCompositeBinaryTree {
    class Node {
        let order: (Element, Element) -> Bool
        var balance: Int { return 0 }
        
        init(order: @escaping (Element, Element) -> Bool) {
            self.order = order
        }
        
        func insert(_ newData: Element) throws -> Node {
            return InnerNode(newData, order: order)
        }
        
        func contains(_ data: Element) -> Bool {
            return false
        }
        
        func removeLast() -> (data: Element?, node: Node) {
            return (nil, self)
        }
        
        func pop() -> (data: Element?, node: Node) {
            return (nil, self)
        }
        
        func remove(_ data: Element) throws -> Node {
            throw DataStructureError.notIn
        }
        
        var array: [Element] {
            return []
        }
        
        var count: UInt {
            return 0
        }
        
        var dotDescription: String {
            return ""
        }
    }
}

extension AVLCompositeBinaryTree {
    class InnerNode: Node {
        var data: Element
        var left: Node
        var right: Node
        var internalBalance: Int = -1
        override var balance: Int { return internalBalance }
        
        init(_ newData: Element, order: @escaping (Element, Element) -> Bool, left: Node? = nil, right: Node? = nil) {
            self.data = newData
            self.left = left ?? LeafNode(order: order)
            self.right = right ?? LeafNode(order: order)
            super.init(order: order)
        }
        
        override func removeLast() -> (data: Element?, node: Node) {
            let rightPop = right.removeLast()
            right = rightPop.node
            guard let element = rightPop.data else {
                return (data, left)
            }
            return (element, level())
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
        
        override func remove(_ data: Element) throws -> Node {
            if data == self.data {
                let leftPop = left.removeLast()
                left = leftPop.node
                if let data = leftPop.data {
                    self.data = data
                    return level()
                }
                return right
            } else if order(data, self.data) {
                left = try left.remove(data)
            } else {
                right = try right.remove(data)
            }
            return level()
        }
        
        override func insert(_ newData: Element) throws -> Node {
            guard data != newData else {
                throw DataStructureError.alreadyIn
            }
            if order(newData, self.data) {
                left = try left.insert(newData)
            } else {
                right = try right.insert(newData)
            }
            return level()
        }
        
        override func pop() -> (data: Element?, node: Node) {
            guard !(left is LeafNode) else {
                return (data, right)
            }
            let result = left.pop()
            left = result.node
            return (result.data, level())
        }
        
        private func updateBalance() -> (left: Int, right: Int) {
            let lb = left.balance, rb = right.balance
            self.internalBalance = max(lb, rb) + 1
            return (lb, rb)
        }
        
        private func level() -> Node {
            let balances = updateBalance()
            if balances.left - balances.right > 1 {
                let tmp = (left as? InnerNode)!
                left = tmp.right
                tmp.right = self
                return tmp
            } else if balances.left - balances.right < -1 {
                let tmp = (right as? InnerNode)!
                right = tmp.left
                tmp.left = self
                return tmp
            }
            return self
        }
        
        override var array: [Element] {
            return left.array + [data] + right.array
        }
        
        override var count: UInt {
            return left.count + right.count + 1
        }
        
        override var dotDescription: String {
            var a = ""
            if let left = left as? InnerNode {
                a += "\t\t\(self.data) -> \( left.data) [label=left] \n"
            }
            if let right = right as? InnerNode {
                a += "\t\t\(self.data) -> \(right.data) [label=right]\n"
            }
            
            return a + left.dotDescription + right.dotDescription
        }
    }
}

extension AVLCompositeBinaryTree {
    class LeafNode: Node {}
}
