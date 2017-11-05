//
//  BxTreeLinkedLinked.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 05.11.17.
//

import Foundation

// swiftlint:disable trailing_whitespace file_length

public struct BxTreeLinked<Element: Hashable> {
    private var root: Node
    public let maxInnerNodeSize: Int
    public let maxLeafNodeSize: Int
    public var minInnerNodeSize: Int {
        return (maxInnerNodeSize + 1) >> 1
    }
    public var minLeafNodeSize: Int {
        return (maxLeafNodeSize + 1) >> 1
    }
    
    public init(maxInnerNodeSize: Int, maxLeafNodeSize: Int) {
        self.maxInnerNodeSize = maxInnerNodeSize
        self.maxLeafNodeSize = maxLeafNodeSize
        self.root = LeafNode(maxSize: maxLeafNodeSize)
    }
    
    public init() {
        let cls = cacheLineSize
        let maxInnerNodeSize = cls / MemoryLayout<InnerNode>.size
        let maxLeafNodeSize  = cls / MemoryLayout<Element>.size
        self.init(maxInnerNodeSize: maxInnerNodeSize, maxLeafNodeSize: maxLeafNodeSize)
    }
}

extension BxTreeLinked {
    fileprivate typealias Split = (data: Int, left: Node, right: Node)
    fileprivate typealias KeyValue = (hashValue: Int, data: Element)
    fileprivate enum ChildrenType: CustomStringConvertible {
        case element(Element)
        case node(Node)
        var description: String {
            switch self {
            case let .node(n): return "\(n)"
            case let .element(e): return "\(e)"
            }
        }
    }
    fileprivate typealias Steal = (hashValue: Int, child: ChildrenType)
    
    fileprivate class Node {
        static var levelString: String { return "   " }
        
        var keys: [Int]
        let maxSize: Int
        var minSize: Int {
            return (maxSize) >> 1
        }
        
        fileprivate init(maxSize: Int) {
            self.keys = []
            self.maxSize = maxSize
        }
        
        func index(ofKey key: Int) -> Int {
            return keys.indices.first(where: { key <= keys[$0] }) ?? keys.count
        }
        
        var array: [Element] { return [] }
        var count: UInt { return 0 }
        func insert(_ data: KeyValue) throws -> Split? { return nil }
        func find(key: Int) -> Element? { return nil }
        func remove(_ hashValue: Int) -> Element? { return nil }
        func stealRight() -> Steal? { return nil }
        func stealLeft() -> Steal? { return nil }
        func merge(with node: Node, separator: Int) {}
        
        func isValid(minKey: Int, maxKey: Int) -> Bool {
            guard keys.count <= maxSize else {
                print("keys.count <= maxSize", keys.count, maxSize, self)
                return false
            }
            guard keys.count >= minSize else {
                print("keys.count >= minSize", keys.count, minSize, self)
                return false
            }
            guard keys.first ?? Int.max > minKey else {
                print("keys.first ?? Int.min >= minKey", minKey)
                return false
            }
            guard keys.last ?? Int.min <= maxKey else {
                print("keys.last ?? Int.max <= maxKey", maxKey)
                return false
            }
            return true
        }
        
        var structure: [Any] { return [] }
        func description(depth: Int) -> String { return "" }
    }
}

extension BxTreeLinked {
    fileprivate final class InnerNode: Node {
        var children: [Node]
        
        override func isValid(minKey: Int, maxKey: Int) -> Bool {
            guard super.isValid(minKey: minKey, maxKey: maxKey) else {
                print("super.isValid", self)
                return false
            }
            guard children.count - 1 == keys.count else {
                print("children.count - 1 == keys.count", self)
                return false
            }
            
            for index in children.indices {
                let minKey = index == 0 ? minKey : keys[index - 1]
                let maxKey = index == keys.count ? maxKey : keys[index]
                guard children[index].isValid(minKey: minKey, maxKey: maxKey) else {
                    print("child is not valid")
                    return false
                }
            }
            return true
        }
        
        override init(maxSize: Int) {
            children = []
            super.init(maxSize: maxSize)
        }
        
        override var count: UInt {
            return children.reduce(0) { $0 + $1.count }
        }
        
        override var array: [Element] {
            return children.first?.array ?? []
        }
        
        override func find(key: Int) -> Element? {
            let keyLocation = index(ofKey: key)
            return children[keyLocation].find(key: key)
        }
        
        override func insert(_ data: KeyValue) throws -> Split? {
            defer { assertEqual(keys.count, children.count - 1) }
            let keyLocation = index(ofKey: data.hashValue)
            let wrappedResult = try children[keyLocation].insert(data)
            
            guard let result = wrappedResult else {
                return nil
            }
            
            let resultKeyLocation = index(ofKey: result.data)
            keys.insert(result.data, at: resultKeyLocation)
            children[resultKeyLocation] = result.left
            children.insert(result.right, at: resultKeyLocation + 1)
            
            guard keys.count <= maxSize else {
                let mid = minSize + 1
                let sibling = InnerNode(maxSize: maxSize)
                let midKey = keys[mid - 1]
                sibling.keys = Array(keys[mid...])
                self.keys = Array(keys[..<(mid-1)])
                sibling.children = Array(children[mid...])
                self.children = Array(children[..<mid])
                
                assertEqual(self.keys.count, self.children.count - 1)
                assertEqual(sibling.keys.count, sibling.children.count - 1)
                
                return (data: midKey, left: self, right: sibling) as Split
            }
            
            return nil
        }
        
        override func description(depth: Int) -> String {
            let start = "\(Node.levelString * UInt(depth))"
            
            let dropLast = keys.indices.reduce("") {
                $0 + children[$1].description(depth: depth + 1) + start + keys[$1].description + "\n"
            }
            
            return dropLast + (children.last?.description(depth: depth + 1) ?? "nil")
        }
        
        override func remove(_ hashValue: Int) -> Element? {
            let keyLocation = index(ofKey: hashValue)
            
            guard let element = children[keyLocation].remove(hashValue) else {
                print(children[keyLocation], "did not remove", hashValue)
                return nil
            }
            
            if children[keyLocation].keys.count < children[keyLocation].minSize {
                shrink(at: keyLocation)
            }
            
            return element
        }
        
        override func stealRight() -> Steal? {
            guard keys.count > minSize else { return nil }
            return (keys.removeLast(), .node(children.removeLast()))
        }
        
        override func stealLeft() -> Steal? {
            guard keys.count > minSize else { return nil }
            return (keys.remove(at: 0), .node(children.remove(at: 0)))
        }
        
        func shrink(at index: Int) {
            let childAtIndex = children[index]
            if index > 0, let r = children[index - 1].stealRight() {
                let tmp = keys[index - 1]
                switch r.child {
                case .element(let element):
                    keys[index - 1] = r.hashValue - 1
                    (childAtIndex as? LeafNode)!.elements.insert(element, at: 0)
                    childAtIndex.keys.insert(r.hashValue, at: 0)
                case .node(let node):
                    keys[index - 1] = r.hashValue
                    (childAtIndex as? InnerNode)!.children.insert(node, at: 0)
                    childAtIndex.keys.insert(tmp, at: 0)
                }
                return
            }
            if index + 1 < children.count, let l = children[index + 1].stealLeft() {
                let tmp = keys[index]
                keys[index] = l.hashValue
                switch l.child {
                case .element(let element):
                    (childAtIndex as? LeafNode)!.elements.append(element)
                    childAtIndex.keys.append(l.hashValue)
                case .node(let node):
                    (childAtIndex as? InnerNode)!.children.append(node)
                    childAtIndex.keys.append(tmp)
                }
                return
            }
            assertEqual(keys.count, children.count - 1)
            let i = max(min(index, keys.count - 1), 0)
            let node = children.remove(at: i+1)
            let key = keys.remove(at: i)
            children[i].merge(with: node, separator: key)
        }
        
        override var structure: [Any] {
            return children.map { $0.structure }
        }
        
        override func merge(with node: Node, separator: Int) {
            guard let node = node as? InnerNode else {
                assert(false)
                return
            }
            keys += [separator] + node.keys
            children += node.children
        }
    }
}

extension BxTreeLinked {
    fileprivate final class LeafNode: Node {
        var elements: [Element]
        var next: LeafNode?
        var previous: LeafNode?
        
        override init(maxSize: Int) {
            elements = []
            super.init(maxSize: maxSize)
        }
        
        override var count: UInt {
            return UInt(elements.count)
        }
        
        override var array: [Element] {
            return elements + (next?.array ?? [])
        }
        
        override func isValid(minKey: Int, maxKey: Int) -> Bool {
            guard super.isValid(minKey: minKey, maxKey: maxKey) else {
                print("super.isValid", self)
                return false
            }
            guard elements.count == keys.count else {
                print("elements.count == keys.count", self)
                return false
            }
            guard elements.map({ $0.hashValue }) == keys else {
                print("elements.map({ $0.hashValue }) == keys", self)
                return false
            }
            return true
        }
        
        override func find(key: Int) -> Element? {
            let keyLocation = index(ofKey: key)
            guard keys.indices.contains(keyLocation) && keys[keyLocation] == key else {
                return nil
            }
            return elements[keyLocation]
        }
        
        override func description(depth: Int) -> String {
            return "\(Node.levelString * UInt(depth))\(elements)\n"
        }
        
        override func stealRight() -> Steal? {
            guard keys.count > minSize else { return nil }
            return (keys.removeLast(), .element(elements.removeLast()))
        }
        
        override func stealLeft() -> Steal? {
            guard keys.count > minSize else { return nil }
            return (keys.remove(at: 0), .element(elements.remove(at: 0)))
        }
        
        override func insert(_ data: KeyValue) throws -> Split? {
            defer { assertEqual(keys.count, elements.count) }
            guard keys.count > 0 else {
                keys.insert(data.hashValue, at: 0)
                elements.insert(data.data, at: 0)
                return nil
            }
            
            let keyLocation = index(ofKey: data.hashValue)
            guard !keys.indices.contains(keyLocation) || keys[keyLocation] != data.hashValue else {
                throw DataStructureError.alreadyIn
            }
            
            keys.insert(data.hashValue, at: keyLocation)
            elements.insert(data.data, at: keyLocation)
            
            guard keys.count <= maxSize else {
                let mid = minSize
                let sibling = LeafNode(maxSize: maxSize)
                sibling.next = self.next
                self.next = sibling
                sibling.previous = self
                let midKey = keys[mid-1]
                sibling.keys = Array(keys[mid...])
                self.keys = Array(keys[..<mid])
                sibling.elements = Array(elements[mid...])
                self.elements = Array(elements[..<mid])
                
                return (data: midKey, left: self, right: sibling) as Split
            }
            
            return nil
        }
        
        override func remove(_ hashValue: Int) -> Element? {
            defer { assertEqual(keys.count, elements.count) }
            defer { assert(elements.map { $0.hashValue } == keys, self.description) }
            let keyLocation = index(ofKey: hashValue)
            guard keys.indices.contains(keyLocation) && keys[keyLocation] == hashValue else {
                return nil
            }
            keys.remove(at: keyLocation)
            return elements.remove(at: keyLocation)
        }
        
        override var structure: [Any] {
            return elements
        }
        
        override func merge(with node: Node, separator: Int) {
            guard let node = node as? LeafNode else {
                assert(false)
                return
            }
            node.next?.previous = self
            self.next = node.next
            self.keys += node.keys
            self.elements += node.elements
        }
    }
}

extension BxTreeLinked: DataStructure {
    public mutating func remove(_ data: Element) throws {
        guard remove(data.hashValue) != nil else {
            throw DataStructureError.notIn
        }
    }
    
    @discardableResult
    public mutating func remove(_ hashValue: Int) -> Element? {
        defer { assert(isValid, self.description) }
        let element = root.remove(hashValue)
        if let rootInner = root as? InnerNode, rootInner.children.count < 2 {
            self.root = rootInner.children.first ?? LeafNode(maxSize: maxLeafNodeSize)
        }
        return element
    }
    
    public var description: String {
        return "\(BxTreeLinked.self)\n" + root.description(depth: 0)
    }
    
    public mutating func insert(_ data: Element) throws {
        defer { assert(isValid, self.description) }
        let newData = (hashValue: data.hashValue, data: data)
        guard let result = try root.insert(newData) else {
            return
        }
        let newRoot = InnerNode(maxSize: maxInnerNodeSize)
        newRoot.children = [result.left, result.right]
        newRoot.keys = [result.data]
        root = newRoot
    }
    
    public func find(key: Int) -> Element? {
        return root.find(key: key)
    }
    
    public var count: UInt {
        return root.count
    }
    
    public var array: [Element] {
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
    
    public var isValid: Bool {
        switch root {
        case let root as InnerNode:
            guard root.children.count - 1 == root.keys.count else {
                print("root.children.count - 1 == root.keys.count", self)
                return false
            }
            for index in root.children.indices {
                let minKey = index == 0 ? Int.min : root.keys[index - 1]
                let maxKey = index == root.keys.count ? Int.max : root.keys[index]
                guard root.children[index].isValid(minKey: minKey, maxKey: maxKey) else {
                    print("child is not valid")
                    return false
                }
            }
            return true
        case let root as LeafNode:
            guard root.elements.count == root.keys.count else {
                print("root.elements.count == root.keys.count", self)
                return false
            }
            guard root.elements.map({ $0.hashValue }) == root.keys else {
                print("root.elements.map({ $0.hashValue }) == root.keys", self)
                return false
            }
            return true
        default: return false
        }
    }
    
    public mutating func removeAll() {
        root = LeafNode(maxSize: maxLeafNodeSize)
    }
    
    public var structure: [Any] {
        return root.structure
    }
    
    public typealias DataElement = Element
    
}

extension BxTreeLinked.LeafNode: CustomStringConvertible {
    public var description: String {
        return "\(BxTreeLinked.LeafNode.self): " + "\(keys.indices.map { (key: keys[$0], value: elements[$0]) })"
    }
}

extension BxTreeLinked.InnerNode: CustomStringConvertible {
    var description: String {
        let lastDescription: String
        if let last = children.last {
            lastDescription = "\(last)"
        } else {
            lastDescription = ""
        }
        let str = keys.indices.reduce("[") {
            $0 + "\(children[$1]), " + "key: \(keys[$1]), "
            } + "\(lastDescription)]"
        return "\(BxTreeLinked.InnerNode.self): " + str
    }
}
