//
//  Huffman.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 05.08.17.
//  Copyright © 2017 pauljohanneskraft. All rights reserved.
//

// swiftlint:disable trailing_whitespace

protocol HuffmanNode {
    var codes: [Character: String] { get }
}

extension Huffman {
    
    static func generateRoot(codes: [(key: Character, value: String)]) -> HuffmanNode? {
        let zeroStart = codes.filter { $0.value.hasPrefix("0") }
        let oneStart  = codes.filter { $0.value.hasPrefix("1") }
        guard codes.count > 2 else {
            guard let zeroFirst = zeroStart.first, let oneFirst = oneStart.first else {
                guard let codeFirst = codes.first else { return nil }
                return HuffmanLeaf(character: codeFirst.key)
            }
            let leftLeaf = HuffmanLeaf(character: zeroFirst.key)
            let rightLeaf = HuffmanLeaf(character: oneFirst.key)
            return HuffmanInnerNode(left: leftLeaf, right: rightLeaf)
        }
        
        let leftArray  = zeroStart.map { (key: $0.key, value: String($0.value.dropFirst())) }
        let rightArray =  oneStart.map { (key: $0.key, value: String($0.value.dropFirst())) }
        
        guard let leftNode  = Huffman.generateRoot(codes: leftArray ),
              let rightNode = Huffman.generateRoot(codes: rightArray) else {
            return nil
        }

        return HuffmanInnerNode(left: leftNode, right: rightNode)
    }
    
    class HuffmanNode {
        var codes: [Character: String] { return [:] }
        func encoded() -> String {
            return ""
        }
    }

    private class HuffmanInnerNode: HuffmanNode, CustomStringConvertible {
        var left: HuffmanNode
        var right: HuffmanNode
        override var codes: [Character: String] {
            var internalCodes = [Character: String]()
            for code in right.codes {
                internalCodes[code.key] = "1" + code.value
            }
            for code in left.codes {
                internalCodes[code.key] = "0" + code.value
            }
            return internalCodes
        }
        
        override func encoded() -> String {
            return "(\(left.encoded())\(right.encoded()))"
        }
        
        init(left: HuffmanNode, right: HuffmanNode) {
            self.left = left
            self.right = right
        }
        
        var description: String {
            return "(\(self.left), \(self.right))"
        }
    }
    
    private class HuffmanLeaf: HuffmanNode, CustomStringConvertible {
        var character: Character
        init(character: Character) {
            self.character = character
        }
        override var codes: [Character: String] {
            return [character: ""]
        }
        
        override func encoded() -> String {
            return "\(character)"
        }
        
        var description: String {
            return "\"\(character)\""
        }
    }

}

public struct Huffman<Character: Hashable> {
    private var root: HuffmanNode
    private(set) var codes: [Character: String]
    
    init?(codes: [Character: String]) {
        self.codes = codes
        
        guard let root = Huffman.generateRoot(codes: codes.map { $0 }) else {
            return nil
        }
        
        self.root = root
    }
    
    init?<S: Sequence>(optimizedFor sequence: S) where S.Iterator.Element == Character {
        var occurences = [Character: Double]()
        sequence.forEach { char in
            occurences[char] = (occurences[char] ?? 0) + 1
        }
        self.init(occurrenceProbabilities: occurences)
    }
    
    init?(occurrenceProbabilities occ: [Character: Double]) {
        
        func priority(of node: HuffmanNode) -> Double {
            switch node {
            case let inner as HuffmanInnerNode:
                return priority(of: inner.left) + priority(of: inner.right)
            case let leaf as HuffmanLeaf:
                return occ[leaf.character] ?? 0
            default: return 0
            }
        }
        
        var heap = BinaryMaxHeap<HuffmanNode>(
             array: occ.map { HuffmanLeaf(character: $0.key) },
             order: { priority(of: $0) > priority(of: $1) })
        
        while heap.array.count > 1 {
            let first  = heap.pop()!
            let second = heap.pop()!
            heap.push(HuffmanInnerNode(left: first, right: second))
        }
        
        guard let root = heap.pop() else {
            return nil
        }
        
        self.root = root
        self.codes = root.codes
    }
    
    func encodedCodes() -> String {
        return root.encoded()
    }
    
    func encode<S: Sequence>(_ array: S) throws -> (data: [UInt8], length: Int) where S.Iterator.Element == Character {
        var encodedBytes = [UInt8]()
        var stringBytes = [UInt8]()
        for char in array {
            guard let c = self.codes[char] else { throw HuffmanError.unknownCharacter(char) }
            stringBytes.append(contentsOf: c.utf8)
            while stringBytes.count >= 8 {
                let nextByte = Array(stringBytes[0..<8])
                let str = String(cString: nextByte + [0])
                guard let byte = UInt8(str, radix: 2) else {
                    throw HuffmanError.unknownCharacter(str)
                }
                encodedBytes.append(byte)
                stringBytes.removeFirst(8)
            }
        }
        
        let restCount = stringBytes.count
        if restCount > 0 {
            let rest = Array(stringBytes[0..<stringBytes.count])
            let restStr = String(cString: rest + [0])
            let byte = (UInt8(restStr, radix: 2) ?? 0) << UInt8(8 - restCount)
            encodedBytes.append(byte)
        }
        let length = (encodedBytes.count * 8) + (restCount > 0 ? restCount - 8: 0)
        return (encodedBytes, length)
    }
    
    func decode(_ input: (data: [UInt8], length: Int)) throws -> [Character] {
        var node = root
        var decoding = [Character]()
        var index = 0
        for byte in input.data {
            for i in (UInt8(0)..<8).reversed() {
                guard index < input.length else { break }
                index += 1
                let mask = UInt8(1) << i
                guard let innerNode = node as? HuffmanInnerNode else {
                    throw HuffmanError.emptyHeap
                }
                switch byte & mask {
                case 0: node = innerNode.left
                default: node = innerNode.right
                }
                if let leaf = node as? HuffmanLeaf {
                    decoding.append(leaf.character)
                    node = root
                }
            }
        }
        assert(node === root)
        return decoding
    }
    
}

enum HuffmanError: Error {
    case unknownCharacter(Any)
    case emptyHeap
}
