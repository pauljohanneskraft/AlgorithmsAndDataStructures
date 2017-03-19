//
//  Trie.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 27.09.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

extension Trie : DataStructure {}

public class Trie < Element : Hashable > {
    public typealias DataElement = [Element]
	
    public init() {}
	
	fileprivate var children		= [Element:Trie<Element>]()
	internal var wordsAtCurrentLength : UInt	= 0
    
    public var count : UInt {
        return children.values.reduce(0, { $0 + $1.count }) + wordsAtCurrentLength
    }
	
	public func insert(_ word: [Element]) {
		insert(ArraySlice(word))
	}
    
    public func remove(_ word: [Element]) throws {
        _ = try remove(ArraySlice(word))
    }
    
    private func remove(_ word: ArraySlice<Element>) throws -> Bool { // returns, if the node should remain, if empty
        
        guard word.count > 0 else {
            if wordsAtCurrentLength > 0 { wordsAtCurrentLength -= 1 }
            else { throw DataStructureError.notIn }
            return children.count != 0 || count != 0
        }
        
        guard let first = word.first, let c = children[first] else { throw DataStructureError.notIn }
        
        if try !(c.remove(word.dropFirst())) { children.removeValue(forKey: word.first!) }
        return children.count != 0 || wordsAtCurrentLength != 0
    }
    
    private func insert(_ word: ArraySlice<Element>) {
        
        guard word.count > 0 else { wordsAtCurrentLength += 1; return }
        
        if let c = children[word.first!] {
            c.insert(word.dropFirst())
        } else {
            let t = Trie()
            t.insert(word.dropFirst())
            children[word.first!] = t
        }
    }
	
	public var array : [[Element]] {
        get { return getArray(appending: []) }
        set { children = [:]; for i in array { self.insert(i) } }
    }
	
	private func getArray(appending: [Element]) -> [[Element]] {
		
		var result = [[Element]]()
		
		for k in children.keys {
			result.append(contentsOf: children[k]!.getArray(appending: appending + [k]))
		}
		
		for _ in 0..<wordsAtCurrentLength { result.append(appending) }
		
		return result
	}
	
	public static func sort(_ list: inout [[Element]], by order: @escaping (Element, Element) -> Bool) {
		let t = Trie()
		for item in list { t.insert(item) }
        list = t.array.sorted {
            let max = min($0.count, $1.count)
            guard max > 0 else { return $0.count < $1.count ? true : false }
            for i in 0..<max {
                     if order($0[i], $1[i]) { return true  }
                else if order($1[i], $0[i]) { return false }
            }
            return false
        }
	}
}

public extension Trie where Element : Comparable {
	
	public static func sort(_ list: inout [[Element]]) {
		Trie<Element>.sort(&list, by: <)
	}
}

public extension Trie where Element : Comparable & Hashable {
    public var description : String {
        return "\(Trie<Element>.self)" + description(depth: 1)
    }
    
    fileprivate func description(depth: UInt) -> String {
        var result = wordsAtCurrentLength == 0 ? "" : " - \(wordsAtCurrentLength)"
        let spacing = " " * depth
        for k in children.keys.sorted(by: <) {
            result += "\n" + spacing + "∟ \(k)" + children[k]!.description(depth: depth + 1)
        }
        return result
    }
}
