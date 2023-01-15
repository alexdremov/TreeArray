import CollectionsBenchmark
import Benchmarks

var benchmark = Benchmark(title: "TreeArray Benchmarks")
benchmark.registerCustomGenerators()
benchmark.addArrayBenchmarks()
benchmark.main()
