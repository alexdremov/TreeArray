# TreeArray

Swift implementation of implicit treap. Data structure with efficient random insert / remove.

## Usage

TreeArray **behaves like a usual array** but has a different implementation under the hood that allows some operations to work faster. You can just replace `Array` with `TreeArray` and it should work as expected.

```swift
import TreeArray

var foo: TreeArray = [1, 2, 3, 4, 5]
foo.insert(0, at: 0)
print(foo) // [0, 1, 2, 3, 4, 5]
```

## Complexity

According to performance tests, the visible difference starts to appear around 16k elements. After that, `TreeArray` outperform `Array` and `Deque` on random insertions and deletions.

| **Operation**                | **Complexity** | **Complexity Array** |
|------------------------------|----------------|----------------------|
| append                       | `O(log n)`     | `O(1)`               |
| subscript                    | `O(log n)`     | `O(1)`               |
| random insert                | `O(log n)`     | `O(n)`               |
| random delete                | `O(log n)`     | `O(n)`               |
| iteration (iterator)         | `O(n)`         | `O(n)`               |
| iteration (subscript)        | `O(n * log n)` | `O(n)`               |
| build from array             | `O(n)`         | `O(n)`               |
| build from unknown-sized seq | `O(n * log n)` | `O(n)`               |
| reverse                      | `O(n)`         | `O(n)`               |
| contains                     | `O(n)`         | `O(n)`               |
| append array                 | `O(m + log n)` | `O(m)`               |
| insert array                 | `O(m + log n)` | `O(m + n)`           |

## Comparison

The data structure is built upon a self-balancing random search tree. It allows performing random insertions and deletions efficiently with the cost of worse performance on other operations. In the directory [Benchmarks/results](Benchmarks/results) you can explore full comparison results. Here, I will note only the most important cases.

### Random insertions
![](Benchmarks/results/Results/17%20random%20insertions.svg)

### Random removals

![](Benchmarks/results/Results/21%20random%20removals.svg)

### Prepend

![](Benchmarks/results/Results/13%20prepend.svg)

### Remove first

![](Benchmarks/results/Results/20%20removeFirst.svg)

<hr>

However, on other tests, it works worse. For example, iteration or build.

![](Benchmarks/results/Results/02%20init%20from%20unsafe%20buffer.svg)
![](Benchmarks/results/Results/03%20sequential%20iteration.svg)
