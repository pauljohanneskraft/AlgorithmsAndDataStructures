//
//  LazyList.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 09.12.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation


public struct LazyList < Element > {
    var current : Element
    var next : LazyList<Element> {
        return LazyList<Element>(start: rule(current), rule: rule)
    }
    
    public init(start: Element, rule: @escaping (Element) -> Element) {
        self.current = start
        self.rule = rule
    }
    var rule : (Element) -> Element
}

extension LazyList : Collection {
    
    public func lazymap(_ transform: @escaping (Element) -> Element) -> LazyList<Element> {
        let rule = self.rule
        return LazyList<Element>(start: current) { transform(rule($0)) }
    }
    
    public func get(first: UInt) -> [Element] {
        var elems = [Element]()
        var currentList = self
        for _ in 0..<first {
            elems.append(currentList.current)
            currentList = currentList.next
        }
        return elems
    }
    
    public subscript(index: Int) -> Element {
        get {
            var curr = self.current
            for _ in 0..<index { curr = rule(curr) }
            return curr
        }
    }
    
    public func index(after: Int) -> Int { return after + 1 }
    
    public var startIndex : Int { return 0 }
    
    public var endIndex : Int { return Int.max }
    
    public var count : Int { return Int.max }
    
    public var first : Element { return current }
}
