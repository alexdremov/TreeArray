//
//  TreeArray+Collection.swift
//
//
//  Created by Alex Dremov on 11.01.2023.
//

import Foundation

@frozen
public struct TreeArray<T>: ExpressibleByArrayLiteral, RandomAccessCollection {
    public typealias Element = T
    
    @usableFromInline
    internal typealias NodeIndex = Int
    
    @usableFromInline
    internal typealias Storage = COWNodesStorage
    
    @usableFromInline
    internal struct Header {
        var capacity: Int = 0
        var freeSize: Int = 0
        var freePointer: NodeIndex = 0
        
        init(capacity: Int, freeSize: Int, freePointer: NodeIndex) {
            self.capacity = capacity
            self.freeSize = freeSize
            self.freePointer = freePointer
        }
        
        init() {}
    }
    
    @usableFromInline
    internal class COWNodesStorage {
        @usableFromInline
        internal var size: Int
        
        private var storageHeader: Header
        
        private(set) var pointer: UnsafeMutablePointer<TreeNode>
        
        @usableFromInline
        init(capacity: Int) {
            pointer = UnsafeMutablePointer.allocate(capacity: capacity)
            storageHeader = Header(
                capacity: capacity,
                freeSize: 0,
                freePointer: 0
            )
            pointer[0] = TreeNode()
            pointer[0].depth = 0
            size = 0
        }
        
        @usableFromInline
        init(size: Int, storageHeader: Header, pointer: UnsafeMutablePointer<TreeNode>) {
            self.storageHeader = storageHeader
            self.pointer = pointer
            self.size = size
        }
        
        @usableFromInline
        var copy: Storage {
            let newPointer = UnsafeMutablePointer<TreeNode>
                .allocate(capacity: storageHeader.capacity)
            newPointer.initialize(from: pointer, count: storageHeader.capacity)
            return .init(
                size: size,
                storageHeader: storageHeader,
                pointer: newPointer
            )
        }
        
        @usableFromInline
        func requireAdditional(elements: Int) {
            let requireSize = size + storageHeader.freeSize + elements + 1
            if requireSize < storageHeader.capacity {
                return
            }
            
            let increaseFactor = 2
            let newCapacity = requireSize * increaseFactor
            let newStorage = UnsafeMutablePointer<TreeNode>.allocate(capacity: newCapacity)
            newStorage.moveInitialize(from: pointer, count: storageHeader.capacity)
            pointer.deallocate()
            pointer = newStorage
            storageHeader.capacity = newCapacity
        }
        
        @usableFromInline
        func allocateNode() -> NodeIndex {
            if storageHeader.freePointer == 0 {
                requireAdditional(elements: 1)
                size += 1
                pointer[size] = TreeNode()
                return size
            }
            let newNodeValue = storageHeader.freePointer
            assert(newNodeValue > 0, "Zero node is reserved")
            
            storageHeader.freeSize -= 1
            storageHeader.freePointer = pointer[newNodeValue].next
            pointer[newNodeValue].depth = 1
            pointer[newNodeValue].left = 0
            pointer[newNodeValue].right = 0
            size += 1
            return newNodeValue
        }
        
        @usableFromInline
        func deleteNode(at pos: Int) {
            assert(pos > 0, "Zero node is reserved")
            assert(size > 0, "Deleting when size is 0")
            storageHeader.freeSize += 1
            size -= 1
            if storageHeader.freePointer == 0 {
                storageHeader.freePointer = pos
                return
            }
            pointer[pos].key = nil
            pointer[pos].next = storageHeader.freePointer
            storageHeader.freePointer = pos
        }
        
        @usableFromInline
        func deleteSubtree(root: Int) {
            if pointer[root].left != 0 {
                deleteSubtree(root: pointer[root].left)
            }
            if pointer[root].right != 0 {
                deleteSubtree(root: pointer[root].right)
            }
            deleteNode(at: root)
        }
        
        func removeAll() {
            storageHeader = Header(
                capacity: capacity,
                freeSize: 0,
                freePointer: 0
            )
            pointer[0] = TreeNode()
            pointer[0].depth = 0
            size = 0
        }
        
        @inline(__always)
        @usableFromInline
        var capacity: Int {
            storageHeader.capacity
        }
    
        @usableFromInline
        subscript(_ index: Int) -> TreeNode {
            get {
                precondition(index < storageHeader.capacity,  "Accessing uninitialized memory")
                return pointer[index]
            }
            set {
                pointer[index] = newValue
            }
        }
        deinit {
            pointer.deallocate()
        }
    }
    
    @usableFromInline
    var storage: Storage
    
    @usableFromInline
    var head: NodeIndex = 0
    
    @inline(__always)
    @usableFromInline
    var size: Int {
        storage.size
    }
    
    @inline(__always)
    @usableFromInline
    var capacity: Int {
        storage.capacity
    }
    
    @usableFromInline
    internal struct TreeNode {
        @usableFromInline
        internal var key: Element?
        
        @usableFromInline
        internal var priority: Int = Int.random(in: Int.min...Int.max)
        
        @usableFromInline
        internal var depth: Int = 1
        
        @usableFromInline
        internal var left: NodeIndex = 0
        
        @usableFromInline
        internal var right: NodeIndex = 0
        
        @usableFromInline
        internal var next: NodeIndex = 0
        
        @inlinable
        internal init(key: T?, left: Int = 0, right: Int = 0) {
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
        internal func leftDepth(storage: Storage) -> Int {
            leftExists ? storage[left].depth: 0
        }
    }
    
    private mutating func updateDepth(node: NodeIndex) {
        if node == 0 { return }
        let depth =
        (storage[storage[node].left].depth) + (storage[storage[node].right].depth) + 1
        storage[node].depth = depth
    }
    
    @usableFromInline
    mutating func merge(left: NodeIndex = 0, right: NodeIndex = 0) -> NodeIndex {
        if left == 0 || right == 0 {
            return right + left
        }

        if storage[left].priority > storage[right].priority {
            storage[left].right = merge(left: storage[left].right, right: right)
            updateDepth(node: left)
            return left
        } else {
            storage[right].left = merge(left: left, right: storage[right].left)
            updateDepth(node: right)
            return right
        }
    }
    
    @usableFromInline
    mutating func split(node: NodeIndex, no: Int) -> (left: NodeIndex, right: NodeIndex) {
        if node == 0 {
            return (0, 0)
        }
        let curKey = storage[node].leftDepth(storage: storage)
        var ret: (left: NodeIndex, right: NodeIndex) = (0, 0)
        
        if curKey < no {
            if !storage[node].rightExists {
                (storage[node].right, ret.right) = (0, 0)
            } else {
                (storage[node].right, ret.right) =
                split(node: storage[node].right, no: no - curKey - 1)
            }
            ret.left = node
        } else {
            if !storage[node].leftExists {
                (ret.left, storage[node].left) = (0, 0)
            } else {
                (ret.left, storage[node].left) =
                split(node: storage[node].left, no: no)
            }
            ret.right = node
        }
        
        updateDepth(node: ret.left)
        updateDepth(node: ret.right)
        
        return ret
    }
    
    func getIndexOf(node: NodeIndex, x: Int) -> NodeIndex {
        if node == 0 {
            return 0
        }
        let curKey = storage[node].leftDepth(storage: storage)
        if curKey < x {
            return getIndexOf(node: storage[node].right, x: x - curKey - 1)
        } else if curKey > x {
            return getIndexOf(node: storage[node].left, x: x)
        }
        return node
    }
    
    @usableFromInline
    mutating func setAtIndexKnownUniqelyReferenced(node: NodeIndex, x: Int, value: Element) {
        let node = getIndexOf(node: node, x: x)
        if node == 0 {
            fatalError("\(x) not in array")
        }
        storage[node].key = value
    }
    
    @usableFromInline
    mutating func insertKnownUniqelyReferenced(_ newElement: Element, at i: Int) {
        if i < 0 || i > size {
            fatalError("Index \(i) out of range in structure of size \(size)")
        }
        
        let newNodeInd = storage.allocateNode()
        storage[newNodeInd].key = newElement
        if head == 0 {
            head = newNodeInd
            return
        }
        
        let splitted = split(node: head, no: i)
        head = merge(left: merge(left: splitted.left, right: newNodeInd), right: splitted.right)
    }
    
    public mutating func insert(_ newElement: Element, at i: Int) {
        ensureUniqelyReferenced()
        insertKnownUniqelyReferenced(newElement, at: i)
    }
    
    @discardableResult
    @usableFromInline
    mutating func removeKnownUniqelyReferenced(at i: Int) -> T {
        let splitRes = split(node: head, no: i)
        
        if splitRes.right == 0 {
            fatalError("\(i) not in array")
        }
        
        let splittedSecond = split(node: splitRes.right, no: 1)
        let value = storage[splittedSecond.left].key!
        head = merge(left: splitRes.left, right: splittedSecond.right)
        storage.deleteNode(at: splittedSecond.left)
        return value
    }
    
    @discardableResult
    public mutating func remove(at i: Int) -> T {
        ensureUniqelyReferenced()
        return removeKnownUniqelyReferenced(at: i)
    }
    
    var array: [Element] {
        var result = [Element]()
        result.reserveCapacity(Int(size))
        for i in self {
            result.append(i)
        }
        return result
    }
    
    @usableFromInline
    func printFrom(root: NodeIndex) {
        if storage.pointer[root].left != 0 {
            printFrom(root: storage.pointer[root].left)
        }
        print(storage.pointer[root].key!, terminator: " ")
        if storage.pointer[root].right != 0 {
            printFrom(root: storage.pointer[root].right)
        }
    }
    
    public subscript(_ x: Int) -> T {
        get {
            let node = getIndexOf(node: head, x: x)
            if node != 0 {
                return storage[node].key!
            }
            fatalError("Index \(x) out of range in structure of size \(size)")
        }
        mutating set(value) {
            ensureUniqelyReferenced()
            if head == 0 || x >= size {
                fatalError("Index \(x) out of range in structure of size \(size)")
            }
            setAtIndexKnownUniqelyReferenced(node: head, x: x, value: value)
        }
    }
    
    @usableFromInline
    mutating func ensureUniqelyReferenced() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = storage.copy
        }
    }
    
    public init() {
        let initialCapacity = 8
        storage = .init(capacity: initialCapacity)
    }
    
    public init(_ content: [Element]) {
        self.init()
        storage.requireAdditional(elements: content.capacity)
        append(contentsOf: content)
    }
    
    public init(arrayLiteral content: Element...) {
        self.init()
        storage.requireAdditional(elements: content.capacity)
        append(contentsOf: content)
    }
    
    public init<S>(_ content: S) where S: Sequence, Element == S.Element {
        self.init()
        append(contentsOf: content)
    }
}
