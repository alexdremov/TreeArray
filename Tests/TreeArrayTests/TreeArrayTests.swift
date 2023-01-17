import XCTest
import Foundation
@testable import TreeArray

final class TreeArrayTests: XCTestCase {
    func testSimple() {
        var treap = TreeArray<Int>()
        var array = [Int]()

        let testSize = 1024

        for i in 0..<testSize {
            array.append(i)
            treap.append(i)
        }

        for i in 0..<testSize {
            XCTAssertEqual(array[i], treap[i])
        }

        XCTAssertEqual(array.split(separator: 4), treap.split(separator: 4))
    }

    func testSimpleFront() {
        var treap = TreeArray<Int>()
        var array = [Int]()

        let testSize = 2048

        for _ in 0..<testSize {
            let rand = Int.random(in: 0...Int.max)
            array.insert(rand, at: 0)
            XCTAssertNoThrow(treap.insert(rand, at: 0))
        }

        for i in 0..<testSize {
            XCTAssertEqual(array[i], treap[i])
        }
    }

    func testCopyOnWrite() {
        var treap = TreeArray<Int>()
        var array = [Int]()

        let testSize = 2048 * 8

        for _ in 0..<testSize {
            let rand = Int.random(in: 0...Int.max)
            array.insert(rand, at: 0)
            treap.insert(rand, at: 0)
        }

        for i in 0..<testSize {
            XCTAssertEqual(array[i], treap[i])
        }

        let otherTreap = treap

        for i in 0..<testSize {
            XCTAssertEqual(array[i], otherTreap[i])
        }

        for i in 0..<testSize {
            treap[i] = Int.random(in: 0...Int.max)
        }

        for i in 0..<testSize {
            XCTAssertEqual(array[i], otherTreap[i])
        }
    }

    func testArrayLiteral() {
        let treap: TreeArray<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

        for i in 0...10 {
            XCTAssertEqual(treap[i], i)
        }
    }

    func testSeqInsert() {
        var treap: TreeArray<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        var arrResult: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        arrResult.insert(contentsOf: arrResult, at: 9)

        for i in 0...10 {
            XCTAssertEqual(treap[i], i)
        }

        treap.insert(contentsOf: treap.array, at: 9)

        for i in 0..<arrResult.count {
            XCTAssertEqual(treap[i], arrResult[i])
        }
    }

    func testRepeating() {
        let treap = TreeArray<Int>(repeating: 10, count: 100)

        for i in 0..<treap.count {
            XCTAssertEqual(treap[i], 10)
        }
    }

    func testFiltering() {
        var treap: TreeArray<Int> = []
        let testSize = 2048 * 8

        for _ in 0...testSize {
            treap.append(Int.random(in: 0...Int.max))
        }

        let filter = {
            (i: Int) -> Bool in
            i > Int.max / 2
        }
        var countFilter = 0
        for i in treap {
            if filter(i) {
                countFilter += 1
            }
        }

        let filtered = treap.filter(filter)

        XCTAssertEqual(filtered.count, countFilter)

        for i in filtered {
            XCTAssertTrue(filter(i))
        }
    }

    func testIterator() {
        let testSize = 2048 * 8
        let treap = TreeArray<Int>(0..<testSize)

        for (expected, elem) in treap.enumerated() {
            XCTAssertEqual(expected, elem)
        }
    }

    func testIteratorEmpty() {
        let treap = TreeArray<Int>([])

        for _ in treap {
            XCTAssertFalse(true, "Must not be reached")
        }
    }

    func testIteratorModifications() {
        let testSize = 2048 * 8
        var treap = TreeArray<Int>(0..<testSize)

        for (expected, elem) in treap.enumerated() {
            treap.appendFront(12)
            XCTAssertEqual(expected, elem)
        }
    }

    func testDesription () {
        var treap: TreeArray<Int> = [1, 2, 3]
        XCTAssertNoThrow(String(describing: treap))

        treap = TreeArray<Int>()
        XCTAssertNoThrow(String(describing: treap))
    }

    func testAppendSeq() {
        let generalSize = 10000

        var array = [Int](repeating: 0, count: generalSize)
        for i in 0..<array.count {
            array[i] = Int.random(in: 0...Int.max)
        }
        var treap = TreeArray<Int>(array)

        let arrCopy = array

        array.append(contentsOf: arrCopy)
        treap.append(contentsOf: arrCopy)

        XCTAssertEqual(array, treap.array)
    }

    func testAppendSeqSelf() {
        let generalSize = 10000

        var array = [Int](repeating: 0, count: generalSize)
        for i in 0..<array.count {
            array[i] = Int.random(in: 0...Int.max)
        }
        var treap = TreeArray<Int>(array)

        array.append(contentsOf: array)
        treap.append(contentsOf: treap)

        XCTAssertEqual(array, treap.array)
    }

    func testRemoveSubrange() {
        let generalSize = 100

        var array = [Int](repeating: 0, count: generalSize)
        for i in 0..<array.count {
            array[i] = i
        }
        var treap = TreeArray<Int>(array)

        array.removeSubrange(5...42)
        treap.removeSubrange(5...42)

        XCTAssertEqual(array, treap.array)

        array.removeSubrange(5..<42)
        treap.removeSubrange(5..<42)

        XCTAssertEqual(array, treap.array)

        XCTAssertEqual(array, treap.array)
    }

    func testNoUnnededCopy() {
        let generalSize = 1000

        var array = [Int](repeating: 0, count: generalSize)
        for i in 0..<array.count {
            array[i] = i
        }
        var treap = TreeArray<Int>(array)
        let newTreap = treap

        for i in 0..<array.count {
            array[i] = treap[i]
        }

        for i in 0..<array.count {
            array[i] = newTreap[i]
        }

        XCTAssertEqual(treap.storage, newTreap.storage)
        treap[1] = 0
        XCTAssertNotEqual(treap.storage, newTreap.storage)
    }

    func testCopyOnWriteDeallocaton() {
        let generalSize = 10000

        var array = [Int](repeating: 0, count: generalSize)
        for i in 0..<array.count {
            array[i] = i
        }
        var treap: TreeArray? = TreeArray(array)
        let treeCopy = treap!

        autoreleasepool {
            treap = nil
        }
        XCTAssertEqual(treeCopy.array, array)
    }

    func testDeletionsAdditions() {
        let testSize = 10000

        var arr = Array(0...testSize)
        var tree = TreeArray(0...testSize)

        for _ in 0..<(testSize / 2) {
            arr.removeFirst()
            tree.removeFirst()
        }

        for i in 0..<(testSize / 2) {
            arr.append(i)
            tree.append(i)
        }

        XCTAssertEqual(arr, tree.array)
    }

    func testRemoveAll() {
        let testSize = 10000

        var arr = Array(0...testSize)
        var tree = TreeArray(0...testSize)

        arr.removeAll(keepingCapacity: true)
        tree.removeAll(keepingCapacity: true)

        XCTAssertEqual(arr, tree.array)

        for i in 0..<(testSize / 2) {
            arr.append(i)
            tree.append(i)
        }

        XCTAssertEqual(arr, tree.array)

        arr.removeAll(keepingCapacity: false)
        tree.removeAll(keepingCapacity: false)

        XCTAssertEqual(arr, tree.array)
    }

    func testReversedTraversal() {
        let testSize = 10000

        let arr = Array(0...testSize)
        let tree = TreeArray(0...testSize)

        for (i, j) in zip(arr.reversed(), tree.reversed()) {
            XCTAssertEqual(i, j)
        }
    }

    func testRemoveAtIndex() {
        let testSize = 10000

        var arr = Array(0...testSize)
        var tree = TreeArray(0...testSize)

        for i in (5...500).reversed() {
            XCTAssertEqual(arr.remove(at: i), tree.remove(at: i))
        }
    }

    func testEquitable() {
        let seq = Array(0...10000)

        var a: TreeArray<Int> = []
        var b: TreeArray<Int> = []

        for i in seq {
            a.appendFront(i)
            b.append(i)
        }

        b = TreeArray(b.reversed())
        XCTAssertEqual(a, b)
    }

    func testSwapAt() {
        let seq = Array(0..<10000).shuffled()

        var a = Array(0...10000)
        var b = TreeArray(0...10000)

        for i in 0..<(seq.count - 1) {
            a.swapAt(seq[i], seq[i + 1])
            b.swapAt(seq[i], seq[i + 1])
        }

        XCTAssertEqual(a, b.array)
    }

    func testReserveCapacity() {
        var a = TreeArray<Int>()
        let testSize = 100
        a.reserveCapacity(testSize)
        weak var pointerBefore = a.storage
        for i in 0..<testSize {
            a.append(i)
        }
        XCTAssertEqual(pointerBefore, a.storage)
    }

    func testPalindrome() {
        let testSize = 10000
        var a = TreeArray<Int>((0...testSize).shuffled())
        a += a.reversed()

        for i in 0..<(a.count / 2) {
            XCTAssertEqual(a[i], a[a.count - i - 1])
        }
    }

    func testContains() {
        let testSize = 1000
        let a = TreeArray<Int>((1...testSize).shuffled())
        let b = a.array.shuffled()

        for el in b {
            XCTAssertTrue(a.contains(el))
        }

        for el in b {
            XCTAssertFalse(a.contains(-el), "Does not contain \(-el)")
        }
    }

    func testLinearBuildPowerOfTwo() {
        var a = Array(0..<2)
        var b = TreeArray(a)
        XCTAssertEqual(a, b.array)

        a = Array(0..<4)
        b = TreeArray(a)
        XCTAssertEqual(a, b.array)

        a = Array(0..<16)
        b = TreeArray(a)
        XCTAssertEqual(a, b.array)

        a = Array(0..<1024)
        b = TreeArray(a)
        XCTAssertEqual(a, b.array)
    }

    func testLinearBuildNotPowerOfTwo() {
        var a = Array(0..<1)
        var b = TreeArray(a)
        XCTAssertEqual(a, b.array)

        a = Array(0..<5)
        b = TreeArray(a)
        XCTAssertEqual(a, b.array)

        a = Array(0..<11)
        b = TreeArray(a)
        XCTAssertEqual(a, b.array)

        a = Array(0..<15)
        b = TreeArray(a)
        XCTAssertEqual(a, b.array)

        a = Array(0..<1025)
        b = TreeArray(a)
        XCTAssertEqual(a, b.array)
    }

    func testLinearBuildBig() {
        let a = Array(0..<1000000).shuffled()
        let b = TreeArray(a)
        XCTAssertEqual(a, b.array)
    }

    func testReverse() {
        let testSize = 1000000
        var a = Array(0..<testSize).shuffled()
        var b = TreeArray(a)
        XCTAssertEqual(a, b.array)

        a.reverse()
        b.reverse()

        XCTAssertEqual(a, b.array)
    }

    func testReverseEmpty() {
        var a = [Int]()
        var b = TreeArray(a)
        XCTAssertEqual(a, b.array)

        a.reverse()
        b.reverse()

        XCTAssertEqual(a, b.array)
    }

    func testReversed() {
        let testSize = 1000000
        let a = Array(0..<testSize).shuffled()
        let b = TreeArray(a)
        XCTAssertEqual(a.reversed(), b.reversed())
    }

    func testDoNotGrow() {
        let testSize = 100
        var b = TreeArray<Int>()
        b.reserveCapacity(testSize)
        let before = b.capacity

        b.append(contentsOf: (0..<testSize))
        XCTAssertLessThan(Int(b.capacity), testSize * 2)
        XCTAssertEqual(b.capacity, before)
    }

    func testReferenceTypesPreserving() {
        class Foo {
            public let i: Int
            init(i: Int) {
                self.i = i
            }
        }

        let testSize = 10000
        var biz = TreeArray<Foo>()

        for i in 0..<testSize {
            biz.append(Foo(i: i))
        }

        for i in 0..<testSize {
            let actual = biz[i].i
            XCTAssertEqual(i, actual)
        }
    }

    func testMemoryManagement() {
        var counterAlive = 0
        let testSize = 10
        class Foo {
            let onDeinit: () -> Void
            public let i: Int
            init(i: Int, onDeinit: @escaping () -> Void) {
                self.onDeinit = onDeinit
                self.i = i
            }

            deinit {
                onDeinit()
            }
        }

        autoreleasepool {
            var b: TreeArray? = TreeArray<Foo>()

            for i in 0..<testSize {
                counterAlive += 1
                b?.append(
                    Foo(i: i) {
                        counterAlive -= 1
                    }
                )
            }

            b = nil
        }

        XCTAssertEqual(counterAlive, 0)

        var b: TreeArray = TreeArray<Foo>()

        autoreleasepool {
            for i in 0..<testSize {
                counterAlive += 1
                b.append(
                    Foo(i: i) {
                        counterAlive -= 1
                    }
                )
            }
            b.removeSubrange(0..<(testSize / 2))
            for elem in b {
                print(elem.i)
            }
        }

        XCTAssertEqual(counterAlive, b.count)
    }

    func testCopyOnWriteWithReferenceTypes() {
        let testSize = 1000
        var counterAlive = 0
        autoreleasepool {
            class Foo {
                let onDeinit: () -> Void
                public let i: Int
                init(i: Int, onDeinit: @escaping () -> Void) {
                    self.onDeinit = onDeinit
                    self.i = i
                }

                deinit {
                    onDeinit()
                }
            }

            var b: TreeArray = TreeArray<Foo>()

            for i in 0..<testSize {
                counterAlive += 1
                b.append(
                    Foo(i: i) {
                        counterAlive -= 1
                    }
                )
            }

            let otherArray = b

            b.removeSubrange(1..<(testSize - 1))
            XCTAssertEqual(b.size, 2)
            XCTAssertEqual(b[0].i, 0)
            XCTAssertEqual(b[1].i, testSize - 1)

            XCTAssertEqual(counterAlive, testSize)

            for i in 0..<testSize {
                XCTAssertEqual(otherArray[i].i, i)
            }
        }

        XCTAssertEqual(counterAlive, 0)
    }
}
