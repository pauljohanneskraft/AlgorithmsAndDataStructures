//
//  BinaryTree.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct BinaryTree < Element > : _BinTree {
	mutating public func pop() -> Element? {
		var parent	= root
		var current = root?.left
		
		guard current != nil else {
			let data = root?.data
			root = root?.right
			return data
		}
		
		while current?.left != nil {
			parent	= current
			current	= current?.left
		}
		
		let data = current?.data
		
		parent?.left = current?.right
		
		return data
	}

	typealias Node = BinaryTreeNode <Element>
	
	var root : BinaryTreeNode<Element>?
	public let order: (Element, Element) -> Bool
	
	public init(order : @escaping (Element, Element) -> Bool) {
		self.order = order
	}
	
	public mutating func push(_ data: Element) {
		guard root != nil else {
			root = BinaryTreeNode(data: data, order: order)
			return
		}
		root!.push(data)
	}
	
	public var array : [Element] {
		return root != nil ? root!.array : []
	}
}

extension BinaryTree : CustomStringConvertible {
	public var description : String {
		let result = "\(BinaryTree<Element>.self)"
		guard root != nil else { return result + " empty." }
		return "\(result)\n" + root!.description(depth: 1)
	}
}

final class BinaryTreeNode <Element> : _BinTreeNode {
	
	var data : Element
	var right: BinaryTreeNode<Element>? = nil
	var left : BinaryTreeNode<Element>? = nil
	let order: (Element, Element) -> Bool
	
	required init(data: Element, order: @escaping (Element, Element) -> Bool) {
		self.data	= data
		self.order	= order
	}
	
	func push(_ newData: Element) {
		if order(newData, data) {
			guard left != nil else { left = BinaryTreeNode(data: newData, order: order); return }
			left!.push(newData)
		} else {
			guard right != nil else { right = BinaryTreeNode(data: newData, order: order); return }
			right!.push(newData)
		}
	}
	
	var array : [Element] {
		let r = right != nil ? right!.array : []
		let l =  left != nil ?  left!.array : []
		return l + [data] + r
	}
}

extension BinaryTreeNode {
	public func description(depth: UInt) -> String {
		let tab = "   "
		var tabs = tab * depth
		var result = "\(tabs)∟\(data)\n"
		let d : UInt = depth + 1
		tabs += tab
		if left	 != nil { result += left! .description(depth: d) } // else { result += "\(tabs)∟\n" }
		if right != nil { result += right!.description(depth: d) } // else { result += "\(tabs)∟\n" }
		return result
	}
}
