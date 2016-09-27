//
//  Trie.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 27.09.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public class Trie < Element : Hashable > {
	
	public init() {}
	
	var children		= [Element:Trie<Element>]()
	var count : UInt	= 0
	
	public func insert(_ word: [Element]) {
		
		guard word.count > 0 else { count += 1; return }
		
		if let c = children[word[0]] {
			c.insert(word.dropFirst() + [])
		} else {
			let t = Trie()
			t.insert(word.dropFirst() + [])
			children[word[0]] = t
		}
	}
	
	public var array : [[Element]] { return getArray(appending: []) }
	
	private func getArray(appending: [Element]) -> [[Element]] {
		
		var result = [[Element]]()
		
		for k in children.keys.sorted(by: { $0.hashValue < $1.hashValue }) {
			result.append(contentsOf: children[k]!.getArray(appending: appending + [k]))
		}
		
		for _ in 0..<count { result.append(appending) }
		
		return result
	}
	
	public static func sort(_ list: inout [[Element]]) {
		let t = Trie()
		for item in list { t.insert(item) }
		list = t.array
	}
}

extension Trie : CustomStringConvertible {
	public var description : String {
		return "\(Trie<Element>.self)" + description(depth: 1)
	}
	
	private func description(depth: UInt) -> String {
		var result = count == 0 ? "" : " - \(count)"
		let spacing = " " * depth
		for k in children.keys.sorted(by: { $0.hashValue < $1.hashValue }) {
			result += "\n" + spacing + "∟ \(k)" + children[k]!.description(depth: depth + 1)
		}
		return result
	}
}
