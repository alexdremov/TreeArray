//
//  File.swift
//  
//
//  Created by Alex Dremov on 17.01.2023.
//

import Foundation

extension TreeArray {
    @inlinable
    @inline(__always)
    public func optimized() -> TreeArray {
        .init(optimized: self)
    }
}
