//
//  File.swift
//  
//
//  Created by Alex Dremov on 15.01.2023.
//

import Foundation

extension ManagedBuffer: Equatable where Header == Void {
    public static func == (lhs: ManagedBuffer<Header, Element>, rhs: ManagedBuffer<Header, Element>) -> Bool {
        lhs.withUnsafeMutablePointerToElements { lhsp in
            rhs.withUnsafeMutablePointerToElements { rhsp in
                lhsp == rhsp
            }
        }
    }
}

extension UnsafeMutablePointer {
    @inlinable
    subscript(i: UInt) -> Self.Pointee {
        get {
            self[Int(i)]
        }
        set {
            self[Int(i)] = newValue
        }
    }
}

extension RandomAccessCollection where Index == Int {
    @inlinable
    subscript(i: UInt) -> Self.Element {
        get {
            self[Index(i)]
        }
    }
}
