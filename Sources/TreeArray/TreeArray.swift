//
//  TreeArray+Collection.swift
//
//
//  Created by Alex Dremov on 11.01.2023.
//

import Foundation
import SwiftWyhash

extension UInt {
    @usableFromInline
    static var generator = WyRand(seed: 42)
    
    @inlinable
    static var fastRandom: UInt {
        generator.next()
    }
}

@frozen
public struct TreeArray<T>: ExpressibleByArrayLiteral, RandomAccessCollection {
    public typealias Element = T
    
    @usableFromInline
    internal typealias NodeIndex = UInt
    
    @usableFromInline
    internal typealias Storage = ManagedBuffer<Void, TreeNode>
    
    @usableFromInline
    var storage: Storage
    
    @usableFromInline
    var head: NodeIndex = 0
    
    @usableFromInline
    var size: UInt = 0
    
    @inlinable
    var capacity: UInt {
        UInt(storage.capacity)
    }
    
    @usableFromInline
    var freeSize: UInt = 0
    
    @usableFromInline
    var freePointer: NodeIndex = 0
    
    @usableFromInline
    static func createNewStorage(capacity: UInt) -> Storage {
        let instance = Storage.create(minimumCapacity: Int(capacity)){_ in }
        instance.withUnsafeMutablePointerToElements { pointer in
            pointer[0] = TreeNode()
            pointer[0].depth = 0
        }
        return instance
    }
    
    @inlinable
    var storageCopy: Storage {
        let instance = Self.createNewStorage(capacity: capacity)
        storage.withUnsafeMutablePointerToElements { pointer in
            instance.withUnsafeMutablePointerToElements { newPointer in
                newPointer.initialize(from: pointer, count: Int(capacity))
            }
        }
        return instance
    }
    
    @inlinable
    mutating func requireAdditional(elements: UInt) {
        let requireSize = size + freeSize + elements + 1
        if requireSize < capacity {
            return
        }
        
        let increaseFactor: UInt = 2
        let newCapacity = requireSize * increaseFactor
        let newInstance = Self.createNewStorage(capacity: newCapacity)
        storage.withUnsafeMutablePointerToElements { pointer in
            newInstance.withUnsafeMutablePointerToElements { newStorage in
                newStorage.moveInitialize(from: pointer, count: Int(capacity))
            }
        }
        storage = newInstance
    }
    
    @inlinable
    mutating func allocateNode() -> NodeIndex {
        if freePointer == 0 {
            requireAdditional(elements: 1)
            size += 1
            storage.withUnsafeMutablePointerToElements { pointer in
                pointer[Int(size)] = TreeNode()
            }
            return size
        }
        let newNodeValue = freePointer
        assert(newNodeValue > 0, "Zero node is reserved")
        
        freeSize -= 1
        storage.withUnsafeMutablePointerToElements { pointer in
            let inewNodeValue = Int(newNodeValue)
            freePointer = pointer[inewNodeValue].next
            pointer[inewNodeValue].depth = 1
            pointer[inewNodeValue].left = 0
            pointer[inewNodeValue].right = 0
        }
        size += 1
        return newNodeValue
    }
    
    @inlinable
    mutating func deleteNode(at pos: NodeIndex) {
        assert(pos > 0, "Zero node is reserved")
        assert(size > 0, "Deleting when size is 0")
        freeSize += 1
        size -= 1
        if freePointer == 0 {
            freePointer = pos
            return
        }
        storage.withUnsafeMutablePointerToElements { pointer in
            pointer[Int(pos)].key = nil
            pointer[Int(pos)].next = freePointer
        }
        freePointer = pos
    }
    
    @inlinable
    mutating func deleteSubtree(root: NodeIndex) {
        storage.withUnsafeMutablePointerToElements { pointer in
            if pointer[Int(root)].left != 0 {
                deleteSubtree(root: pointer[Int(root)].left)
            }
            if pointer[Int(root)].right != 0 {
                deleteSubtree(root: pointer[Int(root)].right)
            }
        }
        deleteNode(at: root)
    }
    
    @inlinable
    mutating func storageClear() {
        freeSize = 0
        freePointer = 0
        storage.withUnsafeMutablePointerToElements { pointer in
            pointer[0] = TreeNode()
            pointer[0].depth = 0
        }
        size = 0
    }
    
    @usableFromInline
    internal struct TreeNode {
        @usableFromInline
        internal var key: Element?
        
        @usableFromInline
        internal var priority: UInt = .fastRandom
        
        @usableFromInline
        internal var depth: UInt = 1
        
        @usableFromInline
        internal var left: NodeIndex = 0
        
        @usableFromInline
        internal var right: NodeIndex = 0
        
        @usableFromInline
        internal var next: NodeIndex = 0
        
        @inlinable
        internal init(key: T?, left: NodeIndex = 0, right: NodeIndex = 0) {
            self.key = key
            self.left = left
            self.right = right
        }
        
        @inlinable
        internal init() {
        }
        
        @inlinable
        var leftExists: Bool {
            left != 0
        }
        
        @inlinable
        var rightExists: Bool {
            right != 0
        }
        
        @inlinable
        internal func leftDepth(storage: Storage) -> UInt {
            storage.withUnsafeMutablePointerToElements { pointer in
                return leftExists ? pointer[Int(left)].depth: 0
            }
        }
    }
    
    @inlinable
    mutating func updateDepth(node: NodeIndex) {
        if node == 0 { return }
        storage.withUnsafeMutablePointerToElements { storage in
            let depth = (
                storage[Int(storage[Int(node)].left)].depth) +
            (storage[Int(storage[Int(node)].right)].depth) + 1
            storage[Int(node)].depth = depth
        }
    }
    
    @inlinable
    mutating func merge(left: NodeIndex = 0, right: NodeIndex = 0) -> NodeIndex {
        if left == 0 || right == 0 {
            return right + left
        }
        return storage.withUnsafeMutablePointerToElements { storage in
            if storage[Int(left)].priority > storage[Int(right)].priority {
                storage[Int(left)].right = merge(left: storage[Int(left)].right, right: right)
                updateDepth(node: left)
                return left
            } else {
                storage[Int(right)].left = merge(left: left, right: storage[Int(right)].left)
                updateDepth(node: right)
                return right
            }
        }
    }
    
    @inlinable
    mutating func split(node: NodeIndex, no: UInt) -> (left: NodeIndex, right: NodeIndex) {
        if node == 0 {
            return (0, 0)
        }
        return storage.withUnsafeMutablePointerToElements { pointer in
            let inode = Int(node)
            let curKey = pointer[inode].leftDepth(storage: storage)
            var ret: (left: NodeIndex, right: NodeIndex) = (0, 0)
            
            if curKey < no {
                if !pointer[inode].rightExists {
                    (pointer[inode].right, ret.right) = (0, 0)
                } else {
                    (pointer[inode].right, ret.right) =
                    split(node: pointer[inode].right, no: no - curKey - 1)
                }
                ret.left = node
            } else {
                if !pointer[inode].leftExists {
                    (ret.left, pointer[inode].left) = (0, 0)
                } else {
                    (ret.left, pointer[inode].left) =
                    split(node: pointer[inode].left, no: no)
                }
                ret.right = node
            }
            
            updateDepth(node: ret.left)
            updateDepth(node: ret.right)
            
            return ret
        }
    }
    
    @inlinable
    func getIndexOf(node: NodeIndex, x: UInt) -> NodeIndex {
        if node == 0 {
            return 0
        }
        return storage.withUnsafeMutablePointerToElements { pointer in
            let inode = Int(node)
            let curKey = pointer[inode].leftDepth(storage: storage)
            if curKey < x {
                return getIndexOf(node: pointer[inode].right, x: x - curKey - 1)
            } else if curKey > x {
                return getIndexOf(node: pointer[inode].left, x: x)
            }
            return node
        }
    }
    
    @inlinable
    mutating func setAtIndexKnownUniqelyReferenced(node: NodeIndex, x: UInt, value: Element) {
        let node = getIndexOf(node: node, x: x)
        if node == 0 {
            fatalError("\(x) not in array")
        }
        storage.withUnsafeMutablePointerToElements { pointer in
            pointer[Int(node)].key = value
        }
    }
    
    @inlinable
    mutating func insertKnownUniqelyReferenced(_ newElement: Element, at i: Int) {
        if i < 0 || i > size {
            fatalError("Index \(i) out of range in structure of size \(size)")
        }
        
        let newNodeInd = allocateNode()
        storage.withUnsafeMutablePointerToElements { pointer in
            pointer[Int(newNodeInd)].key = newElement
        }
        if head == 0 {
            head = newNodeInd
            return
        }
        
        let splitted = split(node: head, no: UInt(i))
        head = merge(left: merge(left: splitted.left, right: newNodeInd), right: splitted.right)
    
    }
    
    @inlinable
    public mutating func insert(_ newElement: Element, at i: Int) {
        ensureUniqelyReferenced()
        insertKnownUniqelyReferenced(newElement, at: i)
    }
    
    @inlinable
    @discardableResult
    mutating func removeKnownUniqelyReferenced(at i: Int) -> T {
        let splitRes = split(node: head, no: UInt(i))
        
        if splitRes.right == 0 {
            fatalError("\(i) not in array")
        }
        
        let splittedSecond = split(node: splitRes.right, no: 1)
        return storage.withUnsafeMutablePointerToElements { pointer in
            let value = pointer[Int(splittedSecond.left)].key!
            head = merge(left: splitRes.left, right: splittedSecond.right)
            deleteNode(at: splittedSecond.left)
            return value
        }
        
    }
    
    @inlinable
    @discardableResult
    public mutating func remove(at i: Int) -> T {
        ensureUniqelyReferenced()
        return removeKnownUniqelyReferenced(at: i)
    }
    
    @inlinable
    var array: [Element] {
        var result = [Element]()
        result.reserveCapacity(Int(size))
        for i in self {
            result.append(i)
        }
        return result
    }
    
    @inlinable
    public subscript(_ x: Int) -> T {
        get {
            let node = getIndexOf(node: head, x: UInt(x))
            if node != 0 {
                return storage.withUnsafeMutablePointerToElements { pointer in
                    pointer[Int(node)].key!
                }
            }
            fatalError("Index \(x) out of range in structure of size \(size)")
        }
        mutating set(value) {
            ensureUniqelyReferenced()
            if head == 0 || x >= size {
                fatalError("Index \(x) out of range in structure of size \(size)")
            }
            setAtIndexKnownUniqelyReferenced(node: head, x: UInt(x), value: value)
        }
    }
    
    @inlinable
    mutating func ensureUniqelyReferenced() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = storageCopy
        }
    }
    
    @inlinable
    mutating func constructEmptyHeap(elementsNum: UInt) {
        assert(size == 0 && elementsNum > 0, "Cannot cunstruct empty heap when not empty")
        requireAdditional(elements: elementsNum + 1)
        storage.withUnsafeMutablePointerToElements { rootPointer in
            func heapify(node: UnsafeMutablePointer<TreeNode>) {
                var max = node;
                let t = node.pointee
                if (t.leftExists && rootPointer[t.left].priority > max.pointee.priority){
                    max = rootPointer + Int(t.left)
                }
                if (t.rightExists && rootPointer[t.right].priority > max.pointee.priority){
                    max = rootPointer + Int(t.right)
                }
                if (max != node) {
                    swap(&node.pointee.priority, &max.pointee.priority)
                    heapify(node: max)
                }
            }
            
            func build(n: UInt, pointer: UnsafeMutablePointer<TreeNode>) -> UnsafeMutablePointer<TreeNode> {
                if (n == 0) {
                    return rootPointer
                }
                let mid = n / 2
                pointer[Int(mid)] = TreeNode(
                    key: nil,
                    left: UInt(rootPointer.distance(to: build(n: mid, pointer: pointer))),
                    right: UInt(rootPointer.distance(to: build(n: n - mid - 1, pointer: pointer + Int(mid) + 1)))
                )
                heapify(node: pointer + Int(mid))
                updateDepth(node: UInt(rootPointer.distance(to: pointer + Int(mid))))
                return pointer + Int(mid)
            }
            
            let built = build(n: elementsNum, pointer: rootPointer + 1)
            head = UInt(rootPointer.distance(to: built))
            size = elementsNum
        }
    }
    
    @inlinable
    public init() {
        let initialCapacity: UInt = 8
        storage = Self.createNewStorage(capacity: initialCapacity)
    }
    
    @inlinable
    public init(_ content: [Element]) {
        var pointer: UnsafeBufferPointer<Element>!
        content.withUnsafeBufferPointer { pointer_ in
            pointer = pointer_
        }
        self.init(pointer)
    }
    
    @inlinable
    public init(_ content: UnsafeBufferPointer<Element>) {
        self.init()
        guard !content.isEmpty else {
            return
        }
        constructEmptyHeap(elementsNum: UInt(content.count))
        storage.withUnsafeMutablePointerToElements { pointer in
            for (i, elem) in content.enumerated() {
                pointer[i + 1].key = elem
            }
        }
    }
    
    @inlinable
    public init(arrayLiteral content: Element...) {
        self.init(content)
    }
    
    @inlinable
    public init<S>(_ content: S) where S: Sequence, Element == S.Element {
        self.init()
        append(contentsOf: content)
    }
}

