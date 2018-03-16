//
//  DataStructure.swift
//  Algorithms&DataStructures
//
//  Created by Paul Kraft on 06.11.17.
//

// swiftlint:disable trailing_whitespace

public protocol DataStructure {
    associatedtype DataElement
    mutating func insert(_: DataElement) throws
    mutating func remove(_: DataElement) throws
    func contains(_: DataElement) -> Bool
    mutating func removeAll()
    var count: UInt { get }
    var array: [DataElement] { get set }
}

public protocol IndexedDataStructure: DataStructure {
    associatedtype KeyElement
    mutating func insert(_: DataElement) throws
    func find(key: KeyElement) -> DataElement?
    mutating func remove(at index: KeyElement) -> DataElement?
    mutating func removeAll()
    var count: UInt { get }
    var array: [DataElement] { get set }
}

extension IndexedDataStructure where KeyElement == Int, DataElement: Hashable {
    public mutating func remove(_ data: DataElement) throws {
        guard remove(at: data.hashValue) != nil else {
            throw DataStructureError.notIn
        }
    }
    
    public func contains(_ data: DataElement) -> Bool {
        return find(key: data.hashValue) == data
    }
}
