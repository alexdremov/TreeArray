//
//  File.swift
//  
//
//  Created by Alex Dremov on 15.01.2023.
//

import Foundation

extension TreeArray: RangeReplaceableCollection {
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, T == S.Element {
        ensureUniqelyReferenced()
        for elem in newElements {
            insertKnownUniqelyReferenced(elem, at: size)
        }
    }
    
    public mutating func removeAll(keepingCapacity keepCapacity: Bool) {
        head = 0
        if keepCapacity {
            storage.removeAll()
            return
        }
        storage = Storage(capacity: 8)
    }
    
    public mutating func reserveCapacity(_ n: Int) {
        ensureUniqelyReferenced()
        guard n > capacity else {
            return
        }
        storage.requireAdditional(elements: n - capacity)
    }
    
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, T == C.Element {
        removeSubrange(subrange)
        insert(contentsOf: newElements, at: subrange.startIndex)
    }
}
