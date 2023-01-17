//
//  File.swift
//  
//
//  Created by Alex Dremov on 15.01.2023.
//

import Foundation

extension TreeArray {
    
    @inlinable
    @inline(__always)
    mutating func ensureUniqelyReferenced() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = storageCopy
        }
    }
    
    @inlinable
    @inline(__always)
    var usedStorageSpace: Int {
        freeSize + size + 1 // + 1 on behalf of zero node
    }
    
    /**
     - returns: uninitialized buffer
     */
    @inlinable
    @inline(__always)
    static func createNewStorage(capacity: Int) -> Storage {
        Storage.create(
            minimumCapacity: Swift.max(capacity, 1),
            makingHeaderWith: {_ in }
        )  as! Storage
    }
    
    @inlinable
    var storageCopy: Storage {
        let instance = Self.createNewStorage(capacity: capacity)
        storage.withUnsafeMutablePointerToElements { pointer in
            instance.withUnsafeMutablePointerToElements { newPointer in
                newPointer.initialize(repeating: TreeNode(), count: usedStorageSpace)
                newPointer.assign(from: pointer, count: usedStorageSpace)
            }
        }
        return instance
    }
    
    @inlinable
    mutating func requireAdditional(elements: Int) {
        let requireSize = usedStorageSpace + elements
        guard requireSize > capacity else {
            return
        }
        
        let increaseFactor: Int = 2
        let newCapacity = requireSize * increaseFactor
        requireExactlyTotal(newCapacity: newCapacity)
    }
    
    @inlinable
    mutating func requireExactlyTotal(newCapacity: Int) {
        guard newCapacity > capacity else {
            return
        }
        let newInstance = Self.createNewStorage(capacity: newCapacity)
        storage.withUnsafeMutablePointerToElements { pointer in
            newInstance.withUnsafeMutablePointerToElements { newStorage in
                newStorage.initialize(repeating: TreeNode(), count: usedStorageSpace)
                newStorage.assign(from: pointer, count: usedStorageSpace)
            }
        }
        
        storage = newInstance
    }
    
    @inlinable
    mutating func allocateNode() -> NodeIndex {
        if freeSize == 0 {
            requireAdditional(elements: 1)
            size += 1
            storage.withUnsafeMutablePointerToElements { pointer in
                (pointer + size).initialize(to: TreeNode())
            }
            return size
        }
        let newNodeValue = freePointer
        assert(newNodeValue > 0, "Zero node is reserved")
        
        freeSize -= 1
        size += 1
        
        storage.withUnsafeMutablePointerToElements { pointer in
            freePointer = pointer[newNodeValue].next
            pointer[newNodeValue] = TreeNode()
        }
        return newNodeValue
    }
    
    @inlinable
    mutating func deleteNode(at pos: NodeIndex) {
        assert(pos > 0, "Zero node is reserved")
        assert(size > 0, "Deleting when size is 0")
        defer {
            freeSize += 1
            size -= 1
        }
        
        storage.withUnsafeMutablePointerToElements { pointer in
            pointer[pos].key = nil
            pointer[pos].next = 0
        }
        
        if freeSize == 0 {
            freePointer = pos
            return
        }
        
        storage.withUnsafeMutablePointerToElements { pointer in
            pointer[pos].next = freePointer
        }
        
        freePointer = pos
    }
    
    @inlinable
    mutating func deleteSubtree(root: NodeIndex) {
        storage.withUnsafeMutablePointerToElements { pointer in
            if pointer[root].left != 0 {
                deleteSubtree(root: pointer[root].left)
            }
            if pointer[root].right != 0 {
                deleteSubtree(root: pointer[root].right)
            }
        }
        deleteNode(at: root)
    }
    
    @inlinable
    mutating func storageClear() {
        storage.withUnsafeMutablePointerToElements { pointer in
            pointer.deinitialize(count: usedStorageSpace)
            return
        }
        initEmptyStorage()
    }

}

extension ManagedBuffer: Equatable where Header == Void {
    @inlinable
    @inline(__always)
    public static func == (lhs: ManagedBuffer<Header, Element>, rhs: ManagedBuffer<Header, Element>) -> Bool {
        lhs.withUnsafeMutablePointerToElements { lhsp in
            rhs.withUnsafeMutablePointerToElements { rhsp in
                lhsp == rhsp
            }
        }
    }
}
