//
//  DoublyLinkedList.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

class DoublyLinkedList<T> {
    private var root : DoublyLinkedItem<T>
    init(array: [T]) {
        root = DoublyLinkedItem<T>(prev: nil, info: array[0], next: nil)
        for i in 1..<array.count {
            insert(array[i])
        }
    }
    func insert(_ element: T) {
        root.insert(element)
    }
}

private class DoublyLinkedItem<T> {
    let info : T
    var prev : DoublyLinkedItem?
    var next : DoublyLinkedItem?
    
    init(prev: DoublyLinkedItem?, info: T, next: DoublyLinkedItem?) {
        self.prev = prev
        self.info = info
        self.next = next
    }
    
    func insert(_ element: T) {
        // To Do!
    }
    
}
