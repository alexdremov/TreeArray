//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//
import TreeArray

extension Sequence {
  func kalimbaOrdered() -> TreeArray<Element> {
    var kalimba: TreeArray<Element> = []
    kalimba.reserveCapacity(underestimatedCount)
    var insertAtStart = false
    for element in self {
      if insertAtStart {
        kalimba.insert(element, at: 0)
      } else {
        kalimba.append(element)
      }
      insertAtStart.toggle()
    }
    return kalimba
  }

  func kalimbaOrdered3() -> TreeArray<Element> {
    var odds: TreeArray<Element> = []
    var evens: TreeArray<Element> = []
    odds.reserveCapacity(underestimatedCount)
    evens.reserveCapacity(underestimatedCount / 2)
    var insertAtStart = false
    for element in self {
      if insertAtStart {
        odds.append(element)
      } else {
        evens.append(element)
      }
      insertAtStart.toggle()
    }
    odds.reverse()
    odds.append(contentsOf: evens)
    return odds
  }

}
