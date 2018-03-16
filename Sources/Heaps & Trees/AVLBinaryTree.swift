//
//  AVLBinaryTree.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct AVLBinaryTree<Element: Equatable>: Tree {
    public func contains(_ data: Element) -> Bool {
        return root?.contains(data) ?? false
    }
    
    public mutating func remove(_ data: Element) throws {
        guard let node = try root?.remove(data) else {
            throw DataStructureError.notIn
        }
        root = node
    }
    
    public mutating func removeAll() {
        root = nil
    }
    
    private var root: Node?
    public let order: (Element, Element) -> Bool
    
    public init(order: @escaping (Element, Element) -> Bool) {
        self.order = order
    }
    
    public mutating func insert(_ newData: Element) throws {
        guard let nonNil = root else {
            root = Node(newData, order: order)
            return
        }
        root = try nonNil.insert(newData)
    }
    
    public mutating func push(_ data: Element) throws {
        try insert(data)
    }
    
    public mutating func pop() -> Element? {
        guard let result = root?.pop() else {
            return nil
        }
        root = result.node
        return result.data
    }
    
    public var array: [Element] {
        get {
            return root?.array ?? []
        }
        set {
            removeAll()
            newValue.forEach { try? insert($0) }
        }
    }
    
    var dotDescription: String {
        return "\tdigraph g { \n\t\tgraph [ordering = out] \n" + (root?.dotDescription ?? "") + "\t}\n"
    }
    
    public var count: UInt {
        return root?.size ?? 0
    }
}

extension AVLBinaryTree {
    class Node {
        var data: Element
        var left: Node?
        var right: Node?
        let order: (Element, Element) -> Bool
        var balance: Int = -1
        
        init(_ newData: Element, order: @escaping (Element, Element) -> Bool, left: Node? = nil, right: Node? = nil) {
            self.data = newData
            self.order = order
            self.left = left
            self.right = right
        }
        
        func contains(_ data: Element) -> Bool {
            if self.data == data {
                return true
            } else if order(data, self.data) {
                return left?.contains(data) ?? false
            } else {
                return right?.contains(data) ?? false
            }
        }
        
        func insert(_ newData: Element) throws -> Node {
            guard data != newData else {
                throw DataStructureError.alreadyIn
            }
            if order(newData, self.data) {
                guard let nonNil = left else {
                    left = Node(newData, order: order)
                    return level()
                }
                left = try nonNil.insert(newData)
            } else {
                guard let nonNil = right else {
                    right = Node(newData, order: order)
                    return level()
                }
                right = try nonNil.insert(newData)
            }
            return level()
        }
        
        func removeLast() -> (data: Element, node: Node?) {
            if let rightResult = right?.removeLast() {
                right = rightResult.node
                return (rightResult.data, self)
            }
            return (data, left)
        }
        
        func remove(_ data: Element) throws -> Node? {
            if self.data == data {
                guard let leftResult = left?.removeLast() else {
                    return right
                }
                left = leftResult.node
                self.data = leftResult.data
                return self
            } else if order(data, self.data) {
                guard let leftNode = left else {
                    throw DataStructureError.notIn
                }
                left = try leftNode.remove(data)
            } else {
                guard let rightNode = right else {
                    throw DataStructureError.notIn
                }
                right = try rightNode.remove(data)
            }
            return self
        }
        
        func pop() -> (data: Element, node: Node?) {
            guard let leftNode = left else {
                return (data, right)
            }
            let result = leftNode.pop()
            left = result.node
            return (result.data, level())
        }
        
        private func updateBalance() -> (left: Int, right: Int) {
            let lb = left?.balance ?? -1
            let rb = right?.balance ?? -1
            self.balance = max(lb, rb) + 1
            return (lb, rb)
        }
        
        private func level() -> Node {
            let balances = updateBalance()
            if balances.left - balances.right > 1 {
                let tmp = left
                self.left = left!.right
                tmp!.right = self
                return tmp!
            } else if balances.left - balances.right < -1 {
                let tmp = right
                self.right = right!.left
                tmp!.left = self
                return tmp!
            }
            return self
        }
        
        var array: [Element] {
            return (left?.array ?? []) + [data] + (right?.array ?? [])
        }
        
        var size: UInt {
            return (left?.size ?? 0) + (right?.size ?? 0) + 1
        }
        
        var dotDescription: String {
            var a = ""
            if let left = left {
                a += "\t\t\(self.data) -> \( left.data) [label=left] \n"
            }
            if let right = right {
                a += "\t\t\(self.data) -> \(right.data) [label=right]\n"
            }
            
            a += (left?.dotDescription ?? "")
            a += (right?.dotDescription ?? "")
            return a
        }
    }
}
