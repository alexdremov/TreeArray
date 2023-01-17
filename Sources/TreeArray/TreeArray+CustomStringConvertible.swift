//
//  File.swift
//  
//
//  Created by Alex Dremov on 18.01.2023.
//

import Foundation

extension TreeArray: CustomStringConvertible {
    public var description: String {
        var result = ""
        result.reserveCapacity(size)
        for (i, elem) in self.enumerated() {
            result += "\(elem)"
            if i + 1 != size {
                result += ", "
            }
        }
        return "[\(result)]"
    }
}
