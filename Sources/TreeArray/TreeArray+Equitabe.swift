//
//  File.swift
//  
//
//  Created by Alex Dremov on 15.01.2023.
//

import Foundation

extension TreeArray: Equatable where Element: Equatable {
    @inlinable
    public static func == (lhs: TreeArray, rhs: TreeArray) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        for (i, j) in zip(lhs, rhs) {
            guard i == j else {
                return false
            }
        }
        return true
    }

    @inlinable
    public static func == (lhs: TreeArray, rhs: [Element]) -> Bool {
        guard lhs.count == rhs.count else {
            return false
        }

        for (i, j) in zip(lhs, rhs) {
            guard i == j else {
                return false
            }
        }
        return true
    }
    
    public static func == (lhs: [Element], rhs: TreeArray) -> Bool {
        rhs == lhs
    }
}
