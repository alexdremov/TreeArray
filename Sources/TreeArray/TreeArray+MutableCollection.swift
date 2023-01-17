//
//  TreeArray+MutableCollection.swift
//  
//
//  Created by Alex Dremov on 15.01.2023.
//

import Foundation

extension TreeArray: MutableCollection {
    @inlinable
    public mutating func swapAt(_ i: Int, _ j: Int) {
        guard i != j else {
            return
        }
        ensureUniqelyReferenced()
        let nodeI = getIndexOf(node: head, x: i)
        let nodeJ = getIndexOf(node: head, x: j)
        guard nodeI != 0, nodeJ != 0 else {
            fatalError("Unnable to swap \(i) with \(j) in structure of size \(count)")
        }
        storage.withUnsafeMutablePointerToElements { pointer in
            swap(&pointer[Int(nodeI)].key, &pointer[Int(nodeJ)].key)
        }
    }
    
    @inlinable
    mutating public func reverse() {
        guard size > 0 else {
            return
        }
        ensureUniqelyReferenced()
        reverseSubtreeKnownUniqelyReferenced(starting: head)
    }
    
    @inlinable
    mutating func reverseSubtreeKnownUniqelyReferenced(starting: NodeIndex) {
        guard starting != 0 else {
            return
        }
        let istarting = Int(starting)
        storage.withUnsafeMutablePointerToElements { pointer in
            swap(&pointer[istarting].left, &pointer[istarting].right)
            reverseSubtreeKnownUniqelyReferenced(starting: pointer[istarting].left)
            reverseSubtreeKnownUniqelyReferenced(starting: pointer[istarting].right)
        }
    }
}
