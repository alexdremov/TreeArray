//
//  File.swift
//  
//
//  Created by Alex Dremov on 15.01.2023.
//

import Foundation

extension TreeArray: Equatable where Element: Equatable {
    public static func == (lhs: TreeArray, rhs: TreeArray) -> Bool {
        guard lhs.size == rhs.size else {
            return false
        }
        
        for (i, j) in zip(lhs, rhs) {
            guard i == j else {
                return false
            }
        }
        return true
    }
    
    public static func == (lhs: TreeArray, rhs: Array<Element>) -> Bool {
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
}
