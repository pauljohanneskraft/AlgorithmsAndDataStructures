//
//  B-Tree.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 23.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

public struct BTree<Element: Hashable> {
    public let maxNodeSize: Int
    fileprivate var root: Node?
    
    public init?(maxNodeSize: Int) {
        guard maxNodeSize > 2 else { return nil }
        self.root = nil
        self.maxNodeSize = maxNodeSize
    }
}

extension BTree {
    public var array: [Element] {
        get {
            return root?.array ?? []
        }
        set {
            root = nil
            for i in newValue {
                try? insert(i)
            }
        }
    }
    
    public mutating func insert(_ value: Element) throws {
        defer { assert(valid, "\(self)") }
        let data = (hashValue: value.hashValue, element: value)
        guard let oldRoot = root else {
            let newRoot = Node(maxSize: maxNodeSize)
            newRoot.elements = [data]
            root = newRoot
            return
        }
        guard let result = try oldRoot.insert(data, replace: false) else { return }
        let newRoot = Node(maxSize: maxNodeSize)
        newRoot.children = [result.left, result.right]
        newRoot.elements = [result.keyValue]
        root = newRoot
    }
    
    public mutating func replace(_ value: Element) {
        defer { assert(valid, "\(self)") }
        let data = (hashValue: value.hashValue, element: value)
        guard let oldRoot = root else {
            let newRoot = Node(maxSize: maxNodeSize)
            newRoot.elements = [data]
            root = newRoot
            return
        }
        guard let res = try? oldRoot.insert(data, replace: true), let result = res else { return }
        let newRoot = Node(maxSize: maxNodeSize)
        newRoot.children = [result.left, result.right]
        newRoot.elements = [result.keyValue]
        root = newRoot
    }
    
    public mutating func contains(_ value: Int) -> Bool {
        return root?.contains(value) ?? false
    }
    
    public subscript(hashValue: Int) -> Element? {
        get { return root?.get(hashValue: hashValue) }
    }
    
    @discardableResult
    public mutating func remove(hashValue: Int) -> Element? {
        defer { assert(valid, "\(self), \(hashValue)") }
        let elem = root?.remove(hashValue: hashValue)
        guard root?.children.count != 1 else { root = root!.children[0]; return elem }
        if root?.elements.isEmpty ?? false { root = nil }
        return elem
    }
    
    public var valid: Bool {
        return root?.valid(root: true, min: Int.min, max: Int.max) ?? true
    }
    public var count: Int { return root?.count ?? 0 }
    
    public var height: Int { return root?.height ?? 0 }
    
}

extension BTree: CustomStringConvertible {
    public var description: String {
        return "\(BTree<Element>.self)\n" + (root?.description(depth: 1) ?? "...")
    }
}

extension BTree {
    fileprivate final class Node {
        typealias KeyValue = (hashValue: Int, element: Element)
        let maxChildrenCount: Int
        var elements: [KeyValue]
        var children: [Node]
        var maxElementsCount: Int { return maxChildrenCount - 1 }
        var minChildrenCount: Int { return (maxChildrenCount + 1) / 2 }
        var minElementsCount: Int { return minChildrenCount - 1 }
        
        required init(maxSize: Int) {
            self.maxChildrenCount = maxSize
            self.elements = []
            self.children = []
        }
    }
}

extension BTree.Node {
    typealias Split = (keyValue: KeyValue, left: BTree.Node, right: BTree.Node)
    typealias Steal = (keyValue: KeyValue, node: BTree.Node?)
    
    public var array: [Element] {
        guard !children.isEmpty else { return elements.map { $0.element } }
        return elements.indices.reduce([Element]()) { indexA, indexB in
            indexA + children[indexB].array + [elements[indexB].element]
        } + children.last!.array
    }
    
    func get(hashValue: Int) -> Element? {
        for i in elements.indices {
            guard elements[i].hashValue < hashValue else {
                guard elements[i].hashValue != hashValue else { return elements[i].element }
                guard !children.isEmpty else { return nil }
                return children[i].get(hashValue: hashValue)
            }
        }
        return children.last?.get(hashValue: hashValue)
    }
    
    func getIndex(hashValue: Int) -> Int? {
        return elements.indices.first(where: { elements[$0].hashValue >= hashValue })
    }
    
    func insert(_ data: KeyValue, replace: Bool) throws -> Split? {
        let i = getIndex(hashValue: data.hashValue) ?? elements.count
        guard i == elements.count || elements[i].hashValue != data.hashValue else {
            guard replace else {
                throw DataStructureError.alreadyIn
            }
            elements[i] = data
            return nil
        }
        if children.isEmpty {
            elements.insert(data, at: i)
        } else {
            guard let res = try children[i].insert(data, replace: replace) else { return nil }
            elements.insert(res.0, at: i)
            children[i] = res.1
            children.insert(res.2, at: i + 1)
        }
        guard elements.count > maxElementsCount else { return nil }
        return split()
    }
    
    func split() -> Split {
        let middle = elements.count >> 1
        let nodeLeft = BTree.Node(maxSize: maxChildrenCount)
        let nodeRight = BTree.Node(maxSize: maxChildrenCount)
        nodeLeft.elements = Array(elements[0..<middle])
        nodeRight.elements = Array(elements[(middle + 1)..<elements.count])
        guard !children.isEmpty else { return (elements[middle], nodeLeft, nodeRight) }
        nodeLeft.children = Array(children[0...middle])
        nodeRight.children = Array(children[(middle + 1)...elements.count])
        return (elements[middle], nodeLeft, nodeRight)
    }
    
    func stealLeft() -> Steal? {
        guard elements.count > minElementsCount else { return nil }
        guard !children.isEmpty else { return (elements.remove(at: 0), nil) }
        return (elements.remove(at: 0), children.remove(at: 0))
    }
    
    func stealRight() -> Steal? {
        guard elements.count > minElementsCount else { return nil }
        return (elements.popLast()!, children.popLast())
    }
    
    func remove(hashValue: Int) -> Element? {
        let i = getIndex(hashValue: hashValue) ?? elements.count
        let elem: Element?
        if i < elements.count && elements[i].hashValue == hashValue {
            elem = elements[i].element
            guard !children.isEmpty else {
                return elements.remove(at: i).element
            }
            elements[i] = children[i].removeMax()
        } else {
            guard !children.isEmpty else { return nil }
            elem = children[i].remove(hashValue: hashValue)
        }
        guard !children[i].validSize else { return elem }
        shrink(at: i)
        return elem
    }
    
    func shrink(at index: Int) {
        var i = index
        if i > 0 {
            if let r = children[i - 1].stealRight() {
                let tmp = elements[i - 1]
                elements[i - 1] = r.keyValue
                if let node = r.node {
                    children[i].children.insert(node, at: 0)
                }
                children[i].elements.insert(tmp, at: 0)
                return
            }
        }
        if i + 1 < children.count {
            if let l = children[i + 1].stealLeft() {
                let tmp = elements[i]
                elements[i] = l.keyValue
                if let node = l.node {
                    children[i].children.append(node)
                }
                children[i].elements.append(tmp)
                return
            }
        }
        if i >= elements.count { i = elements.count - 1 }
        children[i] = BTree.Node.merge(
            separator: elements.remove(at: i),
            left: children.remove(at: i),
            right: children[i]
        )
        return

    }
    
    func removeMax() -> KeyValue {
        guard !children.isEmpty else { return elements.popLast()! }
        let max = children.last!.removeMax()
        guard !children.last!.validSize else { return max }
        shrink(at: elements.count)
        return max
    }
    
    static func merge(separator: KeyValue, left: BTree.Node, right: BTree.Node) -> BTree.Node {
        left.elements.append(separator)
        let new = BTree.Node(maxSize: left.maxChildrenCount)
        new.children = left.children + right.children
        new.elements = left.elements + right.elements
        return new
    }
    
    func contains(_ hashValue: Int) -> Bool {
        guard let i = getIndex(hashValue: hashValue) else { return children.last?.contains(hashValue) ?? false }
        guard elements[i].hashValue != hashValue else { return true }
        guard !children.isEmpty else { return false }
        return children[i].contains(hashValue)
    }
    
    var count: Int { return elements.count + children.reduce(0) { $0 + $1.count } }
    
    var height: Int { return 1 + (children.first?.height ?? 0) }

    func valid(root: Bool, min: Int, max: Int) -> Bool {
        guard root || children.count == 0 || children.count >= minChildrenCount else {
            print("minSize")
            return false
        }
        guard children.count <= maxChildrenCount else { print("maxSize"); return false }

        let h = height
        for c in children.indices {
            guard children[c].height + 1 == h else { print("height"); return false }
            let min = (elements.indices.contains(c - 1) ? elements[c - 1].hashValue: min)
            let max = (elements.indices.contains(c) ? elements[c].hashValue: max)
            guard children[c].valid(root: false, min: min, max: max) else {
                print("minmax")
                return false
            }
        }
        
        guard !elements.contains(where: { $0.hashValue <= min || $0.hashValue >= max  }) else {
            return false
        }
        
        return true
    }
    
    var validSize: Bool {
        return elements.count >= minElementsCount && elements.count <= maxElementsCount
    }
    
    func description(depth: Int) -> String {
        let start = "\("\t" * UInt(depth))\(elements.map { $0.hashValue }) \n"
        return children.reduce(start) { $0 + $1.description(depth: depth + 1) }
    }
    
}
