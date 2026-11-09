# Profile Reading Guide

Quick reference for interpreting common profiler output. Tool names are given so the reader can map them to their stack; check each tool's documentation for exact flags in the version in use.

## Profile types and what they can show

| Type | Shows | Blind to |
|---|---|---|
| CPU sampling (on-CPU) | Where threads burn CPU | Time blocked on I/O, locks, sleep |
| Wall-clock / off-CPU | Where time passes, including waiting | Distinguishing compute from wait unless split |
| Allocation profile | Who allocates, how much | What is retained |
| Heap snapshot | What is retained and by whom | Allocation churn already collected |
| Lock / mutex / block profile | Where threads wait for each other | CPU cost |
| Distributed trace | Latency across services and calls | Fine-grained in-process cost |

## Flame graph reading rules

- The x-axis is alphabetical or merged stacks, not time. A flame chart (time-ordered) is a different view.
- Width = share of samples. Inclusive cost is the width of a frame; self cost is the part with nothing stacked on top.
- Look for wide plateaus at the top: they are where CPU is actually spent.
- Repeated identical towers under different parents point to shared hot helpers; a reversed (callee-first) view aggregates them.
- Differential flame graphs colour frames by growth or shrinkage between two profiles.

## Language-specific signatures

- **Go (pprof):** `runtime.mallocgc` and `runtime.gcBgMarkWorker` wide means allocation pressure; `runtime.futex`/`sync.(*Mutex).Lock` in block or mutex profiles means contention. `top -cum` vs `top` separates inclusive from self.
- **JVM (JFR, async-profiler):** GC and safepoint frames; `Unsafe.park` indicates waiting; JIT deoptimisation events in JFR.
- **Python (py-spy, cProfile):** cProfile has high overhead and distorts short functions; py-spy samples with low overhead. Time inside C extensions may appear as a single frame. The GIL makes threads look busy without parallel speedup.
- **Node.js (--cpu-prof, clinic):** wide `(garbage collector)` or `(program)` frames; synchronous JSON parse/stringify of large payloads blocking the event loop; event-loop lag metrics confirm blocking.
- **Browser (DevTools Performance):** long tasks over 50 ms on the main thread; layout and style recalculation triggered repeatedly (layout thrashing); scripting vs rendering vs painting split.
- **Native (perf, Instruments):** missing frame pointers produce broken stacks; build with symbols.

## Memory leak method

1. Warm up, take snapshot A.
2. Run the suspect workload for a fixed period, force or wait for GC, take snapshot B.
3. Repeat, take snapshot C.
4. Objects that grow A→B→C, grouped by retainer path, are leak candidates. Large but stable objects are not leaks.

## Amdahl's law worked example

A cause takes 40% of request time (p = 0.4). Making it 4× faster (s = 4): speedup = 1 / (0.6 + 0.1) ≈ 1.43, so a 500 ms request becomes about 350 ms. Eliminating it entirely caps the gain at 1 / 0.6 ≈ 1.67 (about 300 ms). If the budget is 200 ms, this cause alone cannot close the gap.

## Benchmark hygiene

- Warm-up iterations discarded; several measured runs; report median and spread.
- Same hardware, same data size, quiet machine; pin CPU frequency where possible.
- Prevent dead-code elimination in microbenchmarks (consume results).
- Compare distributions; a difference smaller than run-to-run variance is not a result.
