//
//  CompositeBinaryTree.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

struct CompositeBinaryTree<Element>: Tree {
    var root: Node
    
    init(order: @escaping (Element, Element) -> Bool) {
        self.root = Leaf(order: order)
    }
    
    var array: [Element] {
        return root.array
    }
    
    var order: (Element, Element) -> Bool {
        return root.order
    }
    
    mutating func push(_ data: Element) {
        root = root.push(data)
    }
    
    mutating func pop() -> Element? {
        let ret = root.pop()
        self.root = ret.0
        return ret.1
    }
    
    class Node {
        let order: (Element, Element) -> Bool
        
        init(order: @escaping (Element, Element) -> Bool) {
            self.order = order
        }
        
        var array: [Element] { return [] }
        
        func push(_ data: Element) -> Node {
            return InnerNode(data: data, order: order)
        }
        
        func pop() -> (Node, Element?) {
            return (self, nil)
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
        
        override func push(_ newData: Element) -> Node {
            if order(newData, data) {
                left = left.push(newData)
            } else {
                right = right.push(newData)
            }
            return self
        }
        
        override func pop() -> (Node, Element?) {
            if left is Leaf {
                return (right, self.data)
            }
            let (newLeft, data) = left.pop()
            left = newLeft
            return (self, data)
        }
    }
    
    final class Leaf: Node {
        
    }
}
