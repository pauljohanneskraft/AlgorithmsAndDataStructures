//
//  BinomialHeap.swift
//  Algorithms and Data structures
//
//  Created by Paul Kraft on 09.08.16.
//  Copyright © 2016 pauljohanneskraft. All rights reserved.
//

import Foundation

struct BinomialHeap<Element : Comparable> {
    var children : [BinomialTreeNode<Element>]
    var minIndex : Int?
    
    mutating func merge(with heads: [BinomialTreeNode<Element>], ignoreMinimum: Bool) {
        var newChildren = [BinomialTreeNode<Element>]()
        var carry : BinomialTreeNode<Element>? = nil
        var rank = 0
        var treeIndex = 0
        var headsIndex = 0
        while true {
            var a : BinomialTreeNode<Element>? = nil
            var minRank = 0
            
            while treeIndex < children.count {
                let tree = children[treeIndex]
                if(ignoreMinimum && minIndex != nil && tree == children[minIndex!]) {
                    treeIndex += 1
                    continue
                }
                minRank = tree.depth
                if(tree.depth == rank) {
                    a = tree
                    treeIndex += 1
                }
                break
            }
            /*
             * Als nächstes prüfen wir, ob es einen Baum in 'heads' vom Rang 'rank'
             * gibt und aktualisieren den minimalen Rang 'minRank' passend.
             */
            var b : BinomialTreeNode<Element>? = nil
            if headsIndex < heads.count {
                let tree = heads[headsIndex]
                if tree.depth < minRank {
                    minRank = tree.depth
                }
                if tree.depth == rank {
                    b = tree
                    headsIndex += 1
                }
            }
            
            if a == nil && b == nil && carry == nil {
                if treeIndex >= children.count && headsIndex >= heads.count { break }
                    /*
                     * Wenn es keine Bäume im Haufen, keine Bäume in 'heads' und kein
                     * Carry gibt, sind wir fertig.
                     */
                else {
                    /*
                     * Eine Lücke der Ränge, die sowohl im Haufen, als auch in 'heads'
                     * existiert, kann übersprungen werden.
                     */
                    rank = minRank
                    continue
                }
            } else {
                rank += 1
            }
            /*
             * Wir berechnen den nächsten Baum und den Carry-Baum.
             */
            let result = BinomialHeap.add(a, b, carry: carry)
            let x = result.0
            carry = result.1
            if x != nil {
                /*
                 * Evtl. müssen wir das Minimum des neuen Baums aktualisieren.
                 */
                if minIndex == nil || x!.element < children[minIndex!].element {
                    minIndex = newChildren.count
                }
                /*
                 * Wir geben dem Teilbaum ein Callback, welches bei Änderungen durch die decreaseKey()-Operation
                 * aufgerufen wrid.
                 */
                // x.get().setPropagateRootChange(node -> updateTree(sizeCurrent, node));
                newChildren.append(x!)
            }
        }
        children = newChildren;
    }
    
    static func add<E : Comparable>(_ a: BinomialTreeNode<E>?, _ b: BinomialTreeNode<E>?, carry: BinomialTreeNode<E>?)
        -> (result: BinomialTreeNode<E>?, carry: BinomialTreeNode<E>?) {
            var nodes = [BinomialTreeNode<E>?](repeating: nil, count: 3)
            var count = 0
            if a != nil {
                nodes[count] = a
                count += 1
            }
            if b != nil {
                nodes[count] = b
                count += 1
            }
            if carry != nil {
                nodes[count] = carry
                count += 1
            }
            if count <= 1 {
                return (nodes[0], nil)
            } else {
                assert(nodes[0]!.depth == nodes[1]!.depth)
                let res = nodes[2]
                let n0 = nodes[0]!
                let n1 = nodes[1]!
                let c : BinomialTreeNode<E>? = BinomialTreeNode<E>.merge(n0, n1)
                return (res, c)
            }
            
    }
    
    mutating func insert(_ element: Element) {
        merge(with: [BinomialTreeNode(element)], ignoreMinimum: false)
    }
    
    mutating func deleteMin() -> Element? {
        if let minIndex = self.minIndex {
            let result = children[minIndex].element
            
            return result
        } else {
            if children.count == 0 { return nil }
            else {
                resetMinIndex()
                return deleteMin()
            }
        }
    }
    
    mutating func resetMinIndex() {
        var minElement : Element
        if minIndex != nil {
            minElement = children[minIndex!].element
        } else {
            minElement = children[0].element
        }
        for i in self.children.indices {
            let currentElement = self.children[i].element
            if currentElement < minElement {
                minIndex = i
                minElement = currentElement
            }
        }
    }
    
}

struct BinomialTreeNode<Element : Comparable> : Equatable {
    var children = [BinomialTreeNode<Element>]()
    var element: Element
    
    init(_ element: Element) {
        self.element = element
    }
    
    static func merge<E : Comparable>(_ a: BinomialTreeNode<E>, _ b: BinomialTreeNode<E>) -> BinomialTreeNode<E> {
        assert(a.depth == b.depth)
        var c : BinomialTreeNode<E>
        if a.element < b.element {
            c = a
            c.children.append(b)
        } else {
            c = b
            c.children.append(a)
        }
        return c
    }
    
    var depth : Int {
        if children.count == 0 { return 1 }
        return children.max(by: { $0.children.count > $1.children.count })!.children.count
    }
    
}

func == <E : Comparable>(lhs: BinomialTreeNode<E>, rhs: BinomialTreeNode<E>) -> Bool {
    return lhs.element == rhs.element
}
