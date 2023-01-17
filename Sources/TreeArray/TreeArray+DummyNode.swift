//
//  File.swift
//  
//
//  Created by Alex Dremov on 17.01.2023.
//

import Foundation

extension TreeArray.TreeNodeBuffer {
    @inlinable
    var head: TreeArray.NodeIndex {
        get {
            withUnsafeMutablePointerToElements { pointer in
                pointer[0].right
            }
        }
        set {
            withUnsafeMutablePointerToElements { pointer in
                pointer[0].right = newValue
            }
        }
    }
    
    @inlinable
    var size: Int {
        get {
            withUnsafeMutablePointerToElements { pointer in
                pointer[0].left
            }
        }
        set {
            withUnsafeMutablePointerToElements { pointer in
                pointer[0].left = newValue
            }
        }
    }
    
    @inlinable
    var freePointer: TreeArray.NodeIndex {
        get {
            withUnsafeMutablePointerToElements { pointer in
                pointer[0].priority
            }
        }
        set {
            withUnsafeMutablePointerToElements { pointer in
                pointer[0].priority = newValue
            }
        }
    }
    
    @inlinable
    func deinitSubtree(_ subtree: TreeArray.NodeIndex) {
        withUnsafeMutablePointerToElements { pointer in
            if pointer[subtree].rightExists {
                deinitSubtree(pointer[subtree].right)
            }
            if pointer[subtree].leftExists {
                deinitSubtree(pointer[subtree].left)
            }
            (pointer + subtree).deinitialize(count: 1)
        }
    }
}
