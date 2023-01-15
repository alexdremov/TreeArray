//
//  TreeArray+Collection.swift
//  
//
//  Created by Alex Dremov on 11.01.2023.
//

extension TreeArray: Collection, Sequence {
    public struct Iterator: IteratorProtocol {
        public typealias Element = T
        
        private let tree: TreeArray
        private var visitStack: [NodeIndex]
        
        var storage: UnsafeMutablePointer<TreeNode> {
            tree.storage.pointer
        }
        
        var currentNode: NodeIndex? {
            visitStack.last
        }
        
        init(tree: TreeArray) {
            self.init(tree: tree, start: tree.head)
            propagateLeft()
        }
        
        init(tree: TreeArray, start: NodeIndex) {
            self.tree = tree
            visitStack = [ start ]
        }
        
        private mutating func propagateLeft() {
            while let last = visitStack.last,
                  storage[last].leftExists {
                visitStack.append(storage[last].left)
            }
        }
        
        public mutating func next() -> Element? {
            guard let topIndex = visitStack.last else {
                return nil
            }
            let elemToReturn = storage[topIndex].key
            advance(by: 1)
            return elemToReturn
        }
        
        mutating func advance(by: Int) {
            for _ in 0..<by {
                guard let topIndex = visitStack.popLast() else {
                    return
                }
                if storage[topIndex].rightExists {
                    visitStack.append(storage[topIndex].right)
                    propagateLeft()
                }
            }
        }
    }
    
    public func makeIterator() -> Iterator {
        .init(tree: self)
    }
    
    func makeIterator(starting node: NodeIndex) -> Iterator {
        .init(tree: self, start: node)
    }
    
    @inlinable
    public var startIndex: Int {
        0
    }
    
    @inlinable
    public var endIndex: Int {
        Int(size)
    }
    
    @inlinable
    public var isEmpty: Bool {
        size == 0
    }
    
    @inlinable
    public func index(after i: Int) -> Int {
        i + 1
    }
    
    @inlinable
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
        storage.deleteSubtree(root: leftover)
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
    mutating public func append(_ value: Element) {
        insert(value, at: size)
    }
    
    @inlinable
    mutating public func appendFront(_ value: Element) {
        insert(value, at: 0)
    }
}
