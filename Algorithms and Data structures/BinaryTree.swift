//
//  BinaryTree.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 22.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

public struct BinaryTree < Element > : _BinTree {
	typealias Node = BinaryTreeNode <Element>
	
	var root : BinaryTreeNode<Element>?
	public let order: (Element, Element) -> Bool
	
	public init(order : @escaping (Element, Element) -> Bool) {
		self.order = order
	}
	
	public mutating func insert(_ data: Element) {
		guard root != nil else {
			root = BinaryTreeNode(data: data, order: order)
			return
		}
		root!.insert(data)
	}
	
	public var array : [Element] {
		return root != nil ? root!.array : []
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
	
	func insert(_ newData: Element) {
		if order(newData, data) {
			guard left != nil else { left = BinaryTreeNode(data: newData, order: order); return }
			left!.insert(newData)
		} else {
			guard right != nil else { right = BinaryTreeNode(data: newData, order: order); return }
			right!.insert(newData)
		}
	}
	
	var array : [Element] {
		let r = right != nil ? right!.array : []
		let l =  left != nil ?  left!.array : []
		return l + [data] + r
	}
}
