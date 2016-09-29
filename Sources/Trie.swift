//
//  Trie.swift
//  Algorithms_and_Data_structures
//
//  Created by Paul Kraft on 27.09.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public class Trie < Element : Hashable > {
	
	public init(order: @escaping (Element, Element) -> Bool) {
		self.order = order
	}
	
	var children		= [Element:Trie<Element>]()
	var count : UInt	= 0
	let order : (Element, Element) -> Bool
	
	public func insert(_ word: [Element]) {
		
		guard word.count > 0 else { count += 1; return }
		
		if let c = children[word[0]] {
			c.insert(word.dropFirst() + [])
		} else {
			let t = Trie(order: order)
			t.insert(word.dropFirst() + [])
			children[word[0]] = t
		}
	}
	
	public var array : [[Element]] { return getArray(appending: []) }
	
	fileprivate func getArray(appending: [Element]) -> [[Element]] {
		
		var result = [[Element]]()
		
		for k in children.keys.sorted(by: order) {
			result.append(contentsOf: children[k]!.getArray(appending: appending + [k]))
		}
		
		for _ in 0..<count { result.append(appending) }
		
		return result
	}
	
	public static func sort(_ list: inout [[Element]], by order: @escaping (Element, Element) -> Bool) {
		let t = Trie(order: order)
		for item in list { t.insert(item) }
		list = t.array
	}
}

public extension Trie where Element : Comparable {
	public convenience init() {
		self.init(order: { $0 < $1 })
	}
	
	public static func sort(_ list: inout [[Element]]) {
		Trie<Element>.sort(&list, by: { $0 < $1 })
	}
}

extension Trie : CustomStringConvertible {
	public var description : String {
		return "\(Trie<Element>.self)" + description(depth: 1)
	}
	
	fileprivate func description(depth: UInt) -> String {
		var result = count == 0 ? "" : " - \(count)"
		let spacing = " " * depth
		for k in children.keys.sorted(by: order) {
			result += "\n" + spacing + "∟ \(k)" + children[k]!.description(depth: depth + 1)
		}
		return result
	}
}
