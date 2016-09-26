//
//  Trie.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 27.09.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public class Trie < Element : Hashable > {
	
	var children		= [Element:Trie<Element>]()
	var count : UInt	= 0
	
	public func insert(_ word: [Element]) {
		count += 1

		guard word.count > 0 else { return }				
		
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
		
		var c : UInt = 0
		var result = [[Element]]()
		
		for k in children.keys.sorted(by: { $0.hashValue < $1.hashValue }) {
			result.append(contentsOf: children[k]!.getArray(appending: appending + [k]))
			c += children[k]!.count
		}
		
		while c < count {
			result.append(appending)
			c += 1
		}
		
		return result
	}
	
	public static func sort(_ list: inout [[Element]]) {
		let t = Trie()
		for item in list { t.insert(item) }
		list = t.array
	}
}
