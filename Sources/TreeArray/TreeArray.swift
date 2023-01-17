//
//  TreeArray+Collection.swift
//
//
//  Created by Alex Dremov on 11.01.2023.
//

import Foundation
import SwiftWyhash

extension Int {
    @usableFromInline
    static var generator = WyRand(seed: 42)

    @inlinable
    @inline(__always)
    static var fastRandom: Int {
        Int(bitPattern: generator.next())
    }
}

@frozen
public struct TreeArray<T>: ExpressibleByArrayLiteral, RandomAccessCollection {
    public typealias Element = T

    @usableFromInline
    typealias NodeIndex = Int

    @usableFromInline
    typealias Storage = TreeNodeBuffer

    @usableFromInline
    final class TreeNodeBuffer: ManagedBuffer<Void, TreeNode> {
        @inlinable
        @inline(__always)
        deinit {
            deinitSubtree(head)
        }
    }

    @usableFromInline
    struct TreeNode {
        @usableFromInline
        var key: Element?

        @usableFromInline
        var priority: Int = .fastRandom

        @usableFromInline
        var depth: UInt = 1

        @usableFromInline
        var left: NodeIndex = 0

        @usableFromInline
        var right: NodeIndex = 0

        @inlinable
        @inline(__always)
        init(key: T?, left: NodeIndex = 0, right: NodeIndex = 0) {
            self.key = key
            self.left = left
            self.right = right
        }

        @inlinable
        @inline(__always)
        init() {
        }

        @inlinable
        @inline(__always)
        var next: NodeIndex {
            get {
                right
            }
            set {
                right = newValue
            }
        }

        @inlinable
        @inline(__always)
        var leftExists: Bool {
            left != 0
        }

        @inlinable
        @inline(__always)
        var rightExists: Bool {
            right != 0
        }

        @inlinable
        @inline(__always)
        func leftDepth(storage: Storage) -> Int {
            storage.withUnsafeMutablePointerToElements { pointer in
                return leftExists ? Int(pointer[left].depth) : 0
            }
        }
    }

    @usableFromInline
    var storage: Storage

    @inlinable
    @inline(__always)
    var head: NodeIndex {
        get {
            storage.head
        }
        set {
            storage.head = newValue
        }
    }

    @inlinable
    @inline(__always)
    var capacity: Int {
        storage.capacity
    }

    @inlinable
    @inline(__always)
    var size: Int {
        get {
            storage.size
        }
        set {
            storage.size = newValue
        }
    }

    @usableFromInline
    var freeSize: Int = 0

    @usableFromInline
    @inline(__always)
    var freePointer: NodeIndex {
        get {
            storage.freePointer
        }
        set {
            storage.freePointer = newValue
        }
    }
    
    @inlinable
    mutating func updateDepth(node: NodeIndex) {
        if node == 0 { return }
        storage.withUnsafeMutablePointerToElements { storage in
            let depth = (storage[storage[node].left].depth) +
                        (storage[storage[node].right].depth) + 1
            storage[node].depth = depth
        }
    }

    @inlinable
    mutating func merge(left: NodeIndex = 0, right: NodeIndex = 0) -> NodeIndex {
        if left == 0 || right == 0 {
            return right + left
        }
        return storage.withUnsafeMutablePointerToElements { storage in
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
    }

    @inlinable
    mutating func split(node: NodeIndex, no: Int) -> (left: NodeIndex, right: NodeIndex) {
        if node == 0 {
            return (0, 0)
        }
        return storage.withUnsafeMutablePointerToElements { pointer in
            let inode = node
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
    func getIndexOf(node: NodeIndex, x: Int) -> NodeIndex {
        assert(node != 0, "Invalid node \(node)")
        return storage.withUnsafeMutablePointerToElements { pointer in
            let curKey = pointer[node].leftDepth(storage: storage)
            if curKey < x {
                return getIndexOf(node: pointer[node].right, x: x - curKey - 1)
            } else if curKey > x {
                return getIndexOf(node: pointer[node].left, x: x)
            }
            return node
        }
    }

    @inlinable
    mutating func setAtIndexKnownUniqelyReferenced(node: NodeIndex, x: Int, value: Element) {
        let node = getIndexOf(node: node, x: x)
        if node == 0 {
            fatalError("\(x) not in array")
        }
        storage.withUnsafeMutablePointerToElements { pointer in
            pointer[node].key = value
        }
    }

    @inlinable
    mutating func insertKnownUniqelyReferenced(_ newElement: Element, at i: Int) {
        if i < 0 || i > size {
            fatalError("Index \(i) out of range in structure of size \(size)")
        }

        let newNodeInd = allocateNode()
        storage.withUnsafeMutablePointerToElements { pointer in
            pointer[newNodeInd].key = newElement
        }
        if head == 0 {
            head = newNodeInd
            return
        }

        let splitted = split(node: head, no: i)
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
        let splitRes = split(node: head, no: i)

        if splitRes.right == 0 {
            fatalError("\(i) not in array")
        }

        let splittedSecond = split(node: splitRes.right, no: 1)
        return storage.withUnsafeMutablePointerToElements { pointer in
            let value = pointer[splittedSecond.left].key!
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
        result.reserveCapacity(size)
        for i in self {
            result.append(i)
        }
        return result
    }

    @inlinable
    public subscript(_ x: Int) -> T {
        get {
            let node = getIndexOf(node: head, x: x)
            if node != 0 {
                return storage.withUnsafeMutablePointerToElements { pointer in
                    pointer[node].key!
                }
            }
            fatalError("Index \(x) out of range in structure of size \(size)")
        }
        mutating set(value) {
            precondition(!(head == 0 || x >= size), "Index \(x) out of range in structure of size \(size)")
            ensureUniqelyReferenced()
            setAtIndexKnownUniqelyReferenced(node: head, x: x, value: value)
        }
    }

    @inlinable
    mutating func constructEmptyHeap(elementsNum: Int) {
        assert(size == 0 && elementsNum > 0, "Cannot cunstruct empty heap when not empty")
        requireExactlyTotal(newCapacity: elementsNum + 1)
        storage.withUnsafeMutablePointerToElements { rootPointer in
            (rootPointer + 1).initialize(repeating: TreeNode(), count: elementsNum)
        }

        storage.withUnsafeMutablePointerToElements { rootPointer in
            func heapify(node: UnsafeMutablePointer<TreeNode>) {
                var max = node
                let t = node.pointee
                if t.leftExists && rootPointer[t.left].priority > max.pointee.priority {
                    max = rootPointer + t.left
                }
                if t.rightExists && rootPointer[t.right].priority > max.pointee.priority {
                    max = rootPointer + t.right
                }
                if max != node {
                    swap(&node.pointee.priority, &max.pointee.priority)
                    heapify(node: max)
                }
            }

            func build(n: Int, pointer: UnsafeMutablePointer<TreeNode>) -> UnsafeMutablePointer<TreeNode> {
                if n == 0 {
                    return rootPointer
                }
                let mid = n / 2
                pointer[mid] = TreeNode(
                    key: nil,
                    left: rootPointer.distance(to: build(n: mid, pointer: pointer)),
                    right: rootPointer.distance(to: build(n: n - mid - 1, pointer: pointer + mid + 1))
                )
                heapify(node: pointer + mid)
                updateDepth(node: rootPointer.distance(to: pointer + mid))
                return pointer + mid
            }

            let built = build(n: elementsNum, pointer: rootPointer + 1)
            head = rootPointer.distance(to: built)
            size = elementsNum
        }
    }

    @inlinable
    mutating func initEmptyStorage() {
        storage.withUnsafeMutablePointerToElements { pointer in
            pointer.initialize(to: TreeNode())
            pointer[0].depth = 0
        }

        head = 0
        size = 0
        freeSize = 0
        freePointer = 0
    }

    @inlinable
    @inline(__always)
    init(initialCapacity: Int) {
        storage = Self.createNewStorage(capacity: initialCapacity)
        initEmptyStorage()
    }

    @inlinable
    @inline(__always)
    public init() {
        self.init(initialCapacity: 8)
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
        self.init(initialCapacity: Swift.max(content.count, 8))
        guard !content.isEmpty else {
            return
        }
        constructEmptyHeap(elementsNum: content.count)
        storage.withUnsafeMutablePointerToElements { pointer in
            for (i, elem) in content.enumerated() {
                pointer[i + 1].key = elem
            }
        }
    }
    
    @inlinable
    public init(optimized content: TreeArray) {
        self.init(initialCapacity: Swift.max(content.count, 8))
        guard !content.isEmpty else {
            return
        }
        constructEmptyHeap(elementsNum: content.count)
        storage.withUnsafeMutablePointerToElements { pointer in
            for (i, elem) in content.enumerated() {
                pointer[i + 1].key = elem
            }
        }
    }

    @inlinable
    @inline(__always)
    public init(arrayLiteral content: Element...) {
        self.init(content)
    }

    @inlinable
    @inline(__always)
    public init<S>(_ content: S) where S: Sequence, Element == S.Element {
        self.init(initialCapacity: Swift.max(content.underestimatedCount, 8))
        append(contentsOf: content)
    }
    
    @inlinable
    @inline(__always)
    public init<S>(_ content: S) where S: Collection, Element == S.Element {
        self.init(initialCapacity: Swift.max(content.underestimatedCount, 8))
        append(contentsOf: content)
    }
}
