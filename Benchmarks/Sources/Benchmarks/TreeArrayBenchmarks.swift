import CollectionsBenchmark
import TreeArray

extension Benchmark {
  public mutating func addArrayBenchmarks() {
    self.addSimple(
      title: "TreeArray<Int> init from range",
      input: Int.self
    ) { size in
      blackHole(TreeArray(0 ..< size))
    }

    self.addSimple(
      title: "TreeArray<Int> init from unsafe buffer",
      input: [Int].self
    ) { input in
      input.withUnsafeBufferPointer { buffer in
        blackHole(TreeArray(buffer))
      }
    }

    self.addSimple(
      title: "TreeArray<Int> sequential iteration (iterator)",
      input: TreeArray<Int>.self
    ) { input in
      for i in input {
        blackHole(i)
      }
    }
      
      self.addSimple(
        title: "TreeArray<Int> sequential iteration (indices)",
        input: TreeArray<Int>.self
      ) { input in
          for i in 0..<input.count {
              blackHole(input[i])
          }
      }

    self.addSimple(
      title: "TreeArray<Int> subscript get, random offsets",
      input: (TreeArray<Int>, [Int]).self
    ) { input, lookups in
      for i in lookups {
        blackHole(input[i])
      }
    }

    self.addSimple(
      title: "TreeArray<Int> successful contains",
      input: (TreeArray<Int>, [Int]).self
    ) { input, lookups in
      for i in lookups {
        precondition(input.contains(i))
      }
    }

    self.addSimple(
      title: "TreeArray<Int> unsuccessful contains",
      input: (TreeArray<Int>, [Int]).self
    ) { input, lookups in
      let c = input.count
      for i in lookups {
        precondition(!input.contains(i + c))
      }
    }

    self.add(
      title: "TreeArray<Int> mutate through subscript",
      input: (TreeArray<Int>, [Int]).self
    ) { input, lookups in
      return { timer in
        var array = input
        array.reserveCapacity(0) // Ensure unique storage
        timer.measure {
          var v = 0
          for i in lookups {
            array[i] = v
            v += 1
          }
        }
        blackHole(array)
      }
    }

    self.add(
      title: "TreeArray<Int> random swaps",
      input: [Int].self
    ) { input in
      return { timer in
        var array = TreeArray<Int>(0 ..< input.count)
        timer.measure {
          var v = 0
          for i in input {
            array.swapAt(i, v)
            v += 1
          }
        }
        blackHole(array)
      }
    }

    self.add(
      title: "TreeArray<Int> partitioning around middle",
      input: [Int].self
    ) { input in
      return { timer in
        let pivot = input.count / 2
        var array = TreeArray<Int>(input)
        array.reserveCapacity(0) // Force unique storage
        timer.measure {
          let r = array.partition(by: { $0 >= pivot })
          precondition(r == pivot)
        }
        blackHole(array)
      }
    }

    self.add(
      title: "TreeArray<Int> sort",
      input: [Int].self
    ) { input in
      return { timer in
        var array = TreeArray<Int>(input)
        array.reserveCapacity(0) // Force unique storage
        timer.measure {
          array.sort()
        }
        precondition(array.elementsEqual(0 ..< input.count))
      }
    }

    self.addSimple(
      title: "TreeArray<Int> append",
      input: [Int].self
    ) { input in
      var array: TreeArray<Int> = []
      for i in input {
        array.append(i)
      }
      precondition(array.count == input.count)
      blackHole(array)
    }

    self.addSimple(
      title: "TreeArray<Int> append, reserving capacity",
      input: [Int].self
    ) { input in
      var array: TreeArray<Int> = []
      array.reserveCapacity(input.count)
      for i in input {
        array.append(i)
      }
      blackHole(array)
    }

    self.addSimple(
      title: "TreeArray<Int> prepend",
      input: [Int].self
    ) { input in
      var array: TreeArray<Int> = []
      for i in input {
        array.insert(i, at: 0)
      }
      blackHole(array)
    }

    self.addSimple(
      title: "TreeArray<Int> prepend, reserving capacity",
      input: [Int].self
    ) { input in
      var array: TreeArray<Int> = []
      array.reserveCapacity(input.count)
      for i in input {
        array.insert(i, at: 0)
      }
      blackHole(array)
    }

    self.addSimple(
      title: "TreeArray<Int> kalimba",
      input: [Int].self
    ) { input in
      blackHole(input.kalimbaOrdered())
    }

    self.addSimple(
      title: "TreeArray<Int> kalimba fast",
      input: [Int].self
    ) { input in
      blackHole(input.kalimbaOrdered3())
    }

    self.add(
      title: "TreeArray<Int> random insertions",
      input: Insertions.self
    ) { insertions in
      return { timer in
        let insertions = insertions.values
        var array: TreeArray<Int> = []
        timer.measure {
          for i in insertions.indices {
            array.insert(i, at: insertions[i])
          }
        }
        blackHole(array)
      }
    }

    self.add(
      title: "TreeArray<Int> random insertions, reserving capacity",
      input: Insertions.self
    ) { insertions in
      return { timer in
        let insertions = insertions.values
        var array: TreeArray<Int> = []
        array.reserveCapacity(insertions.count)
        timer.measure {
          for i in insertions.indices {
            array.insert(i, at: insertions[i])
          }
        }
        blackHole(array)
      }
    }

    self.add(
      title: "TreeArray<Int> removeLast",
      input: Int.self
    ) { size in
      return { timer in
        var array = TreeArray<Int>(0 ..< size)
        timer.measure {
          for _ in 0 ..< size {
            array.removeLast()
          }
        }
        precondition(array.isEmpty)
        blackHole(array)
      }
    }

    self.add(
      title: "TreeArray<Int> removeFirst",
      input: Int.self
    ) { size in
      return { timer in
        var array = TreeArray<Int>(0 ..< size)
        timer.measure {
          for _ in 0 ..< size {
            array.removeFirst()
          }
        }
        precondition(array.isEmpty)
        blackHole(array)
      }
    }

    self.add(
      title: "TreeArray<Int> random removals",
      input: Insertions.self
    ) { insertions in
      let removals = Array(insertions.values.reversed())
      return { timer in
        var array = TreeArray<Int>(0 ..< removals.count)
        timer.measure {
          for i in removals {
            array.remove(at: i)
          }
        }
        blackHole(array)
      }
    }
  }
}
