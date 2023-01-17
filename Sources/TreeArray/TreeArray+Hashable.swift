//
//  File.swift
//  
//
//  Created by Alex Dremov on 18.01.2023.
//

import Foundation

extension TreeArray: Hashable where Element: Hashable {
    public func hash(into hasher: inout Hasher) {
        for (i, elem) in self.enumerated() {
            hasher.combine((i + 1) ^ elem.hashValue)
        }
    }
}
