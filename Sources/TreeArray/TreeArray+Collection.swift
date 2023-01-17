//
//  TreeArray+Collection.swift
//  
//
//  Created by Alex Dremov on 11.01.2023.
//
import Foundation

extension TreeArray: Collection, Sequence {
    public struct Iterator: IteratorProtocol {
        public typealias Element = T

        @usableFromInline
        let storage: ManagedBuffer<Void, TreeNode>

        @usableFromInline
        var visitStack: ContiguousArray<NodeIndex> = []

        @inlinable
        @inline(__always)
        var currentNode: NodeIndex? {
            visitStack.last
        }

        @inlinable
        @inline(__always)
        init(tree: TreeArray) {
            self.init(tree: tree, start: tree.head)
            propagateLeft()
        }

        @inlinable
        init(tree: TreeArray, start: NodeIndex) {
            self.storage = tree.storage
            visitStack.reserveCapacity(Int(log2(CGFloat(tree.size + 1))) + 2)
            visitStack.append(tree.head)
        }

        @inlinable
        mutating func propagateLeft() {
            var pointer: UnsafeMutablePointer<TreeNode>!
            storage.withUnsafeMutablePointerToElements { pointer_ in
                pointer = pointer_
            }
            while let last = visitStack.last,
                  pointer[Int(last)].leftExists {
                visitStack.append(pointer[Int(last)].left)
            }
        }

        @inlinable
        public mutating func next() -> Element? {
            guard let topIndex = visitStack.last else {
                return nil
            }
            var pointer: UnsafeMutablePointer<TreeNode>!
            storage.withUnsafeMutablePointerToElements { pointer_ in
                pointer = pointer_
            }
            let elemToReturn = pointer[topIndex].key
            advance(by: 1)
            return elemToReturn
        }

        @inlinable
        mutating func advance(by: Int) {
            var pointer: UnsafeMutablePointer<TreeNode>!
            storage.withUnsafeMutablePointerToElements { pointer_ in
                pointer = pointer_
            }
            for _ in 0..<by {
                guard let topIndex = visitStack.popLast() else {
                    return
                }
                if pointer[topIndex].rightExists {
                    visitStack.append(pointer[topIndex].right)
                    propagateLeft()
                }
            }
        }
    }

    @inlinable
    @inline(__always)
    public func makeIterator() -> Iterator {
        .init(tree: self)
    }

    @inlinable
    @inline(__always)
    func makeIterator(starting node: NodeIndex) -> Iterator {
        .init(tree: self, start: node)
    }

    @inlinable
    @inline(__always)
    public var startIndex: Int {
        0
    }

    @inlinable
    @inline(__always)
    public var endIndex: Int {
        Int(size)
    }

    @inlinable
    @inline(__always)
    public var isEmpty: Bool {
        size == 0
    }

    @inlinable
    @inline(__always)
    public func index(after i: Int) -> Int {
        i + 1
    }

    @inlinable
    @inline(__always)
    public func index(before i: Int) -> Int {
        i - 1
    }

    @inlinable
    mutating public func removeSubrange(_ bounds: Range<Int>) {
        if bounds.isEmpty {
            return
        }
        ensureUniqelyReferenced()
        let (left, middle) = split(node: head, no: bounds.startIndex)
        let (leftover, right) = split(node: middle, no: bounds.count)
        self.head = merge(left: left, right: right)
        deleteSubtree(root: leftover)
    }

    @inlinable
    mutating public func insert<S>(contentsOf newElements: S, at i: Int)
    where S: Collection, T == S.Element {
        if newElements.isEmpty {
            return
        }
        ensureUniqelyReferenced()
        for (pos, elem) in newElements.enumerated() {
            insertKnownUniqelyReferenced(elem, at: pos + i)
        }
    }
    
    @inlinable
    @inline(__always)
    mutating public func insert(contentsOf newElements: Array<T>, at i: Int){
        insert(contentsOf: TreeArray(newElements), at: i)
    }
    
    @inlinable
    @inline(__always)
    mutating public func insert(contentsOf newElements: UnsafeBufferPointer<T>, at i: Int){
        insert(contentsOf: TreeArray(newElements), at: i)
    }
    
    @inlinable
    @inline(__always)
    mutating public func append(contentsOf constructedTree: TreeArray) {
        insert(contentsOf: constructedTree, at: size)
    }
    
    @inlinable
    mutating public func insert(contentsOf constructedTree: TreeArray, at i: Int) {
        if constructedTree.isEmpty {
            return
        }
        guard i >= 0, i <= size else {
            fatalError("Unnable to insert at index \(i) in the structure of size \(size)")
        }
        ensureUniqelyReferenced()
        requireAdditional(elements: constructedTree.count)
        let constructedHead = copyTreeIntoThisMemoryKnownEnoughSpace(tree: constructedTree, startingFrom: constructedTree.head)
        let (before, after) = split(node: head, no: i)
        head = merge(
            left: merge(
                left: before,
                right: constructedHead
            ),
            right: after
        )
    }

    @inlinable
    @inline(__always)
    mutating public func append(_ value: Element) {
        insert(value, at: Int(size))
    }

    @inlinable
    @inline(__always)
    mutating public func appendFront(_ value: Element) {
        insert(value, at: 0)
    }
}
