# TreeArray

Swift implementation of implicit treap. Data structure with efficient random inserts/removals.

## Usage

TreeArray behaves like a usual array but has the different implementation under the hood that allows it to work faster on some operations.

```swift
import TreeArray

let foo: TreeArray = [1, 2, 3, 4, 5]
foo.appendFront(0)
print(foo)
```

## Comparison

The datastructure is built upon self-balancing random search tree. It allows to perform random insertions and deletions efficiently with the cost of worser perfomance on other operations. In directory [Benchmarks/results](Benchmarks/results) you can explore full comparison results. Here, I will note only the most important cases.

## Complexity

### Random insertions
![](Benchmarks/results/Results/17%20random%20insertions.svg)

### Random removals

![](Benchmarks/results/Results/21%20random%20removals.svg)

### Prepend

![](Benchmarks/results/Results/13%20prepend.svg)

### Remove first

![](Benchmarks/results/Results/20%20removeFirst.svg)

<hr>

However, on other tests it works worser. For example, iteration or build.

![](Benchmarks/results/Results/02%20init%20from%20unsafe%20buffer.svg)
![](Benchmarks/results/Results/03%20sequential%20iteration.svg)
