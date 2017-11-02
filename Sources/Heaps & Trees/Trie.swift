//
//  Trie.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 27.09.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

extension Trie: DataStructure {}

public struct Trie<Element: Hashable> {
    public typealias DataElement = [Element]
	
    public init() {}
	
	fileprivate var children = [Element: Trie<Element>]()
	internal var wordsAtCurrentLength: UInt	= 0
    
    public var count: UInt {
        return children.values.reduce(0, { $0 + $1.count }) + wordsAtCurrentLength
    }
	
	public mutating func insert(_ word: [Element]) {
		insert(ArraySlice(word))
	}
    
    public mutating func remove(_ word: [Element]) throws {
        _ = try remove(ArraySlice(word))
    }
    
    private mutating func remove(_ word: ArraySlice<Element>) throws -> Bool {
        // returns, if the node should remain, if empty
        
        guard word.count > 0 else {
            guard wordsAtCurrentLength > 0 else {
                throw DataStructureError.notIn
            }
            wordsAtCurrentLength -= 1
            return children.count != 0 || count != 0
        }
        
        guard let first = word.first,
            let rem = try children[first]?.remove(word.dropFirst()) else {
            throw DataStructureError.notIn
        }
        
        if !rem { children.removeValue(forKey: first) }
        return children.count != 0 || wordsAtCurrentLength != 0
    }
    
    private mutating func insert(_ word: ArraySlice<Element>) {
        
        guard word.count > 0 else { wordsAtCurrentLength += 1; return }
        
        if children[word.first!]?.insert(word.dropFirst()) == nil {
            var t = Trie()
            t.insert(word.dropFirst())
            children[word.first!] = t
        }
    }
    
    public func array(sortedBy order: (Element, Element) -> Bool) -> [[Element]] {
        return getArray(appending: [], sortedBy: order)
    }
	
    fileprivate func getArray(appending: [Element], sortedBy: (Element, Element) -> Bool) -> [[Element]] {
		
		var result = [[Element]]()
		
        for _ in 0..<wordsAtCurrentLength { result.append(appending) }

		for k in children.keys.sorted(by: sortedBy) {
			result.append(contentsOf: children[k]!.getArray(appending: appending + [k], sortedBy: sortedBy))
		}
		
		return result
	}
    
    public var array: [[Element]] {
        get {
            return getArray(appending: [], sortedBy: { _, _ in true })
        }
        set {
            children = [:]
            for i in newValue { insert(i) }
        }
    }
    
    public mutating func merge(with other: Trie<Element>) {
        self.wordsAtCurrentLength += other.wordsAtCurrentLength
        for t in other.children {
            if children[t.key]?.merge(with: t.value) == nil {
                children[t.key] = t.value
            }
        }
    }
	
	public static func sort(_ list: inout [[Element]], by order: @escaping (Element, Element) -> Bool) {
		var t = Trie()
		for item in list { t.insert(item) }
        list = t.array(sortedBy: order)
	}
}

extension Trie: Equatable {
    public static func == <E>(lhs: Trie<E>, rhs: Trie<E>) -> Bool {
        func isSmaller(_ one: [E], _ two: [E]) -> Bool {
            guard one.count == two.count, let index = one.indices.first(where: { one[$0] != two[$0] }) else {
                return one.count < two.count
            }
            return one[index].hashValue < two[index].hashValue
        }
        
        let larray = lhs.array.sorted(by: isSmaller)
        let rarray = rhs.array.sorted(by: isSmaller)
        guard larray.count == rarray.count else {
            return false
        }
        for index in larray.indices {
            guard larray[index] == rarray[index] else {
                return false
            }
        }
        return true
    }
}

public extension Trie where Element: Comparable {
	
	public static func sort(_ list: inout [[Element]]) {
		Trie<Element>.sort(&list, by: <)
	}
    
    public var array: [[Element]] {
        return getArray(appending: [], sortedBy: <)
    }
}

public extension Trie where Element: Comparable {
    public var description: String {
        return "\(Trie<Element>.self)" + description(depth: 1)
    }
    
    fileprivate func description(depth: UInt) -> String {
        var result = wordsAtCurrentLength == 0 ? "": " - \(wordsAtCurrentLength)"
        let spacing = " " * depth
        for k in children.keys.sorted(by: <) {
            result += "\n" + spacing + "∟ \(k)" + children[k]!.description(depth: depth + 1)
        }
        return result
    }
}
