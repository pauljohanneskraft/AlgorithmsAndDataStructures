//
//  SinglyLinkedList.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

struct SinglyLinkedList<T> {
    private var root : SinglyLinkedItem<T>
    init(array: [T]) {
        root = SinglyLinkedItem<T>(data: array[0], next: nil)
        for i in 1..<array.count {
            insert(array[i])
        }
    }
    func insert(_ element: T) {
        root.insert(element)
    }
}

private class SinglyLinkedItem<T> {
    let data : T
    var next : SinglyLinkedItem?
    
    init(data: T, next: SinglyLinkedItem?) {
        self.data = data
        self.next = next
    }
    
    func insert(_ element: T) {
        // To Do!
    }
    
}
