import Foundation
import CollectionsBenchmark
import TreeArray

extension Benchmark {
    public mutating func registerCustomGenerators() {
        self.registerInputGenerator(for: TreeArray<Int>.self) { size in
            TreeArray(Array(0 ..< size).shuffled())
        }

        self.registerInputGenerator(for: (TreeArray<Int>, [Int]).self) { size in
            (TreeArray(Array(0 ..< size).shuffled()), Array(0 ..< size).shuffled())
        }
    }
}
