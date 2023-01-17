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
