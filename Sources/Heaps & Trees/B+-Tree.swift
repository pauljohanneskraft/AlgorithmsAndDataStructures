//
//  B+-Tree.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 23.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

struct BxTree<Element: Hashable> {
    var root: Node
    public let maxInnerNodeSize: Int
    public let maxLeafNodeSize: Int
    
    public init(maxInnerNodeSize: Int, maxLeafNodeSize: Int) {
        self.maxInnerNodeSize = maxInnerNodeSize
        self.maxLeafNodeSize = maxLeafNodeSize
        self.root = LeafNode(maxSize: maxLeafNodeSize)
    }
}

extension BxTree {
    typealias Split = (data: Int, left: Node, right: Node)
    typealias KeyValue = (hashValue: Int, data: Element)
    
    class Node {
        var keys: [Int]
        let maxSize: Int
        
        fileprivate init(maxSize: Int) {
            self.keys = []
            self.maxSize = maxSize
        }
        
        func location(ofKey key: Int) -> Int {
            return keys.indices.first(where: { key <= keys[$0] }) ?? keys.count
        }
        
        var array: [Element] { return [] }
        
        var count: UInt {
            return 0
        }
        
        func insert(_ data: KeyValue) throws -> Split? {
            return nil
        }
        
        func find(key: Int) -> Element? {
            return nil
        }
    }
}

extension BxTree {
    final class InnerNode: Node {
        var children: [Node]
        
        override init(maxSize: Int) {
            children = []
            super.init(maxSize: maxSize)
        }
        
        override var count: UInt {
            return children.reduce(0) { $0 + $1.count }
        }
        
        override var array: [Element] {
            return children.reduce([]) { $0 + $1.array }
        }
        
        override func find(key: Int) -> Element? {
            let keyLocation = location(ofKey: key)
            return children[keyLocation].find(key: key)
        }
        
        override func insert(_ data: KeyValue) throws -> Split? {
            defer { assertEqual(keys.count, children.count - 1) }
            let keyLocation = location(ofKey: data.hashValue)
            let wrappedResult = try children[keyLocation].insert(data)
            
            if let result = wrappedResult {
                let resultKeyLocation = location(ofKey: result.data)
                keys.insert(result.data, at: resultKeyLocation)
                children[resultKeyLocation] = result.left
                children.insert(result.right, at: resultKeyLocation + 1)
            } else { return nil }
            
            guard keys.count <= maxSize else {
                let mid = (maxSize + 1) >> 1
                let sibling = InnerNode(maxSize: maxSize)
                let midKey = keys[mid - 1]
                sibling.keys = Array(keys[mid...])
                self.keys = Array(keys[..<(mid-1)])
                sibling.children = Array(children[mid...])
                self.children = Array(children[..<mid])
                
                assertEqual(self.keys.count, self.children.count - 1)
                assertEqual(sibling.keys.count, sibling.children.count - 1)

                let result = (data: midKey, left: self, right: sibling) as Split
                
                return result
            }
            
            return nil
        }
    }
}

extension BxTree {
    final class LeafNode: Node {
        var elements: [Element]
        
        override init(maxSize: Int) {
            elements = []
            super.init(maxSize: maxSize)
        }
        
        override var count: UInt {
            return UInt(elements.count)
        }
        
        override var array: [Element] {
            return elements
        }
        
        override func find(key: Int) -> Element? {
            let keyLocation = location(ofKey: key)
            guard keys.indices.contains(keyLocation) && keys[keyLocation] == key else {
                return nil
            }
            let element = elements[keyLocation]
            return element
        }
        
        override func insert(_ data: KeyValue) throws -> Split? {
            defer { assertEqual(keys.count, elements.count) }
            guard keys.count > 0 else {
                keys.insert(data.hashValue, at: 0)
                elements.insert(data.data, at: 0)
                return nil
            }
            
            let keyLocation = location(ofKey: data.hashValue)
            guard !keys.indices.contains(keyLocation) || keys[keyLocation] != data.hashValue else {
                throw DataStructureError.alreadyIn
            }
            
            keys.insert(data.hashValue, at: keyLocation)
            elements.insert(data.data, at: keyLocation)
                        
            guard keys.count <= maxSize else {
                let mid = (maxSize + 1) >> 1
                let sibling = LeafNode(maxSize: maxSize)
                let midKey = keys[mid-1]
                sibling.keys = Array(keys[mid...])
                self.keys = Array(keys[..<mid])
                sibling.elements = Array(elements[mid...])
                self.elements = Array(elements[..<mid])
                
                let result = (data: midKey, left: self, right: sibling) as Split
                
                return result
            }
            
            return nil
        }
    }
}

extension BxTree {
    mutating func insert(_ data: Element) throws {
        let newData = (hashValue: data.hashValue, data: data)
        guard let result = try root.insert(newData) else {
            return
        }
        let newRoot = InnerNode(maxSize: maxInnerNodeSize)
        newRoot.children = [result.left, result.right]
        newRoot.keys = [result.data.hashValue]
        root = newRoot
    }
    
    func find(key: Int) -> Element? {
        return root.find(key: key)
    }
    
    var count: UInt {
        return root.count
    }
    
    var array: [Element] {
        get {
            return root.array
        }
        set {
            root = LeafNode(maxSize: maxLeafNodeSize)
            for i in newValue {
                _ = try? insert(i)
            }
        }
    }
    
    typealias DataElement = Element
    
}
