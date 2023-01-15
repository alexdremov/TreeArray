//
//  File.swift
//  
//
//  Created by Alex Dremov on 15.01.2023.
//

import Foundation

extension TreeArray: RangeReplaceableCollection {
    @inlinable
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, T == S.Element {
        ensureUniqelyReferenced()
        requireAdditional(elements: UInt(newElements.underestimatedCount))
        for elem in newElements {
            insertKnownUniqelyReferenced(elem, at: Int(size))
        }
    }
    
    @inlinable
    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        head = 0
        if keepCapacity {
            storageClear()
            return
        }
        storage = Self.createNewStorage(capacity: 8)
    }
    
    @inlinable
    public mutating func reserveCapacity(_ n: Int) {
        ensureUniqelyReferenced()
        guard n > capacity else {
            return
        }
        requireAdditional(elements: UInt(n) - capacity)
    }
    
    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, T == C.Element {
        removeSubrange(subrange)
        insert(contentsOf: newElements, at: subrange.startIndex)
    }
}
