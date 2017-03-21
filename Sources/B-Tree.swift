//
//  B-Tree.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 23.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation


public struct BTree<Element : Hashable> {
    
    public let maxNodeSize : Int
    
    fileprivate var root : BTreeNode<Element>?
    
    public init?(maxNodeSize: Int) {
        guard maxNodeSize > 2 else { return nil }
        self.root = nil
        self.maxNodeSize = maxNodeSize
    }
    
    public mutating func insert(_ value: Element) {
        defer { assert(valid, "\(self)") }
        let data = (hashValue: value.hashValue, element: value)
        guard root != nil else {
            root = BTreeNode<Element>(maxSize: maxNodeSize)
            root!.elements = [data]
            return
        }
        guard let res = root?.insert(data, replace: false) else { return }
        root = BTreeNode<Element>(maxSize: maxNodeSize)
        root!.children = [res.1, res.2]
        root!.elements = [res.0]
    }
    
    public mutating func replace(_ value: Element) {
        defer { assert(valid, "\(self)") }
        let data = (hashValue: value.hashValue, element: value)
        guard root != nil else {
            root = BTreeNode<Element>(maxSize: maxNodeSize)
            root!.elements = [data]
            return
        }
        guard let res = root?.insert(data, replace: true) else { return }
        root = BTreeNode<Element>(maxSize: maxNodeSize)
        root!.children = [res.1, res.2]
        root!.elements = [res.0]
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
    public var count : Int { return root?.count ?? 0 }
    
    public var height : Int { return root?.height ?? 0 }
    
}

extension BTree : CustomStringConvertible {
    public var description : String {
        return "\(BTree<Element>.self)\n" + (root?.description(depth: 1) ?? "...")
    }
}

private final class BTreeNode < Element : Hashable > {
    typealias KeyValue = (hashValue: Int, element: Element)
    let maxChildrenCount : Int
    var elements    : [KeyValue]
    var children    : [BTreeNode<Element>]
    var maxElementsCount : Int { return maxChildrenCount - 1 }
    var minChildrenCount : Int { return (maxChildrenCount + 1) / 2 }
    var minElementsCount : Int { return minChildrenCount - 1 }
    
    required init(maxSize: Int) {
        self.maxChildrenCount = maxSize
        self.elements = []
        self.children = []
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
    
    func insert(_ data: (hashValue: Int, element: Element), replace: Bool) -> ((hashValue: Int, element: Element), BTreeNode<Element>, BTreeNode<Element>)? {
        let i = getIndex(hashValue: data.hashValue) ?? elements.count
        guard i == elements.count || elements[i].hashValue != data.hashValue else {
            if replace { elements[i] = data }
            return nil
        }
        if children.isEmpty {
            elements.insert(data, at: i)
        } else {
            guard let res = children[i].insert(data, replace: replace) else { return nil }
            elements.insert(res.0, at: i)
            children[i] = res.1
            children.insert(res.2, at: i + 1)
        }
        guard elements.count > maxElementsCount else { return nil }
        let middle = elements.count >> 1
        let nodeLeft = BTreeNode<Element>(maxSize: maxChildrenCount)
        let nodeRight = BTreeNode<Element>(maxSize: maxChildrenCount)
        nodeLeft.elements = Array(elements[0..<middle])
        nodeRight.elements = Array(elements[(middle + 1)..<elements.count])
        guard !children.isEmpty else { return (elements[middle], nodeLeft, nodeRight) }
        nodeLeft.children = Array(children[0...middle])
        nodeRight.children = Array(children[(middle + 1)...elements.count])
        return (elements[middle], nodeLeft, nodeRight)
    }
    
    func stealLeft() -> (KeyValue, BTreeNode<Element>?)? {
        guard elements.count > minElementsCount else { return nil }
        guard !children.isEmpty else { return (elements.remove(at: 0), nil) }
        return (elements.remove(at: 0), children.remove(at: 0))
    }
    
    func stealRight() -> (KeyValue, BTreeNode<Element>?)? {
        guard elements.count > minElementsCount else { return nil }
        guard !children.isEmpty else { return (elements.popLast()!, nil) }
        return (elements.popLast()!, children.popLast())
    }
    
    func remove(hashValue: Int) -> Element? {
        let i = getIndex(hashValue: hashValue) ?? elements.count
        let elem : Element?
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
    
    func shrink(at i: Int) {
        var i = i
        if i > 0 {
            if let r = children[i - 1].stealRight() {
                let tmp = elements[i - 1]
                elements[i - 1] = r.0
                if r.1 != nil { children[i].children.insert(r.1!, at: 0) }
                children[i].elements.insert(tmp, at: 0)
                return
            }
        }
        if i + 1 < children.count {
            if let l = children[i + 1].stealLeft() {
                let tmp = elements[i]
                elements[i] = l.0
                if l.1 != nil { children[i].children.append(l.1!) }
                children[i].elements.append(tmp)
                return
            }
        }
        if i >= elements.count { i = elements.count - 1 }
        children[i] = BTreeNode<Element>.merge(separator: elements.remove(at: i), left: children.remove(at: i), right: children[i])
        return

    }
    
    func removeMax() -> KeyValue {
        guard !children.isEmpty else { return elements.popLast()! }
        let max = children.last!.removeMax()
        guard !children.last!.validSize else { return max }
        shrink(at: elements.count)
        return max
    }
    
    static func merge(separator: KeyValue, left: BTreeNode<Element>, right: BTreeNode<Element>) -> BTreeNode<Element> {
        left.elements.append(separator)
        let new = BTreeNode<Element>(maxSize: left.maxChildrenCount)
        new.children = left.children + right.children
        new.elements = left.elements + right.elements
        return new
    }
    
    var validSize : Bool {
        return elements.count >= minElementsCount && elements.count <= maxElementsCount
    }
    
    func contains(_ hashValue: Int) -> Bool {
        guard let i = getIndex(hashValue: hashValue) else { return children.last?.contains(hashValue) ?? false }
        guard elements[i].hashValue != hashValue else { return true }
        guard !children.isEmpty else { return false }
        return children[i].contains(hashValue)
    }
    
    var count : Int { return elements.count + children.reduce(0) { $0 + $1.count } }
    
    var height : Int { return 1 + (children.first?.height ?? 0) }

    func valid(root: Bool, min: Int, max: Int) -> Bool {
        guard (root || children.count == 0 || children.count >= minChildrenCount) else { print("minSize"); return false }
        guard children.count <= maxChildrenCount else { print("maxSize"); return false }

        let h = height
        for c in children.indices {
            guard children[c].height + 1 == h else { print("height"); return false }
            guard (children[c].valid(root: false, min: (elements.indices.contains(c - 1) ? elements[c - 1].hashValue : min), max: (elements.indices.contains(c) ? elements[c].hashValue : max))) else { print("minmax"); return false }
        }
        
        for e in elements {
            guard e.hashValue > min && e.hashValue < max else { print("minmax2"); return false }
        }
        
        return true
    }
    
    
    
    func description(depth: Int) -> String {
        return children.reduce("\("\t" * UInt(depth))\(elements.map { $0.hashValue }) \n") { $0 + $1.description(depth: depth + 1) }
    }
    
}




















