# Concurrency Bug Patterns

Pattern catalogue with typical signatures and fixes. Confirm language-specific semantics in the relevant memory model or runtime documentation.

## Atomicity violations

| Pattern | Example | Fix direction |
|---|---|---|
| Check-then-act | `if (!map.containsKey(k)) map.put(k, v)` | Atomic `putIfAbsent` / `computeIfAbsent`, unique constraint, lock |
| Read-modify-write | `count = count + 1` from several threads | Atomic increment, lock, single-writer actor |
| Lazy init race | Two threads both initialise a singleton | Language-provided once/lazy primitives (`sync.Once`, holder idiom, `lazy`) |
| Compound collection ops | Iterating a concurrent collection while another thread mutates and expecting a snapshot | Copy under lock or use snapshot semantics explicitly |
| Database check-then-insert | SELECT to check existence, then INSERT | Unique constraint with conflict handling, `INSERT ... ON CONFLICT`, conditional UPDATE with row count check |
| Lost update | Read row, modify in app, write back | Optimistic concurrency (version column), `SELECT ... FOR UPDATE`, atomic UPDATE expression |

## Order violations

- Using an object before its initialisation is published to other threads (unsafe publication).
- Registering a listener after the event can fire.
- Message consumer acknowledging before processing completes (or processing before a dependent write is committed).

## Deadlocks

- **Lock-order inversion:** thread 1 holds A wants B; thread 2 holds B wants A. Fix with a global ordering.
- **Thread-pool self-deadlock:** tasks in a bounded pool block waiting for subtasks queued in the same pool.
- **Async-over-sync deadlock:** blocking on an async result from a thread that the continuation needs (for example `.Result` on a UI or single-threaded synchronisation context in C#).
- **Database deadlocks** across application locks and row locks taken in different orders.

Coffman conditions (all four required): mutual exclusion, hold and wait, no preemption, circular wait. Breaking any one prevents deadlock; ordering breaks circular wait.

## Livelock and starvation

- Retry loops that collide repeatedly without jittered backoff.
- Unfair locks or priority scheduling starving low-priority work.
- CAS loops under heavy contention spinning without progress.

## Async-specific

| Runtime | Common hazard |
|---|---|
| JavaScript / Node.js | Missing `await`; unhandled promise rejection; shared module-level state across concurrent requests; CPU-heavy synchronous work blocking the event loop |
| Python asyncio | Calling blocking I/O inside coroutines; tasks created without keeping references; cancellation interrupting a multi-step update |
| Kotlin coroutines | Launching in `GlobalScope` (leaks); mutable state shared across dispatchers without `Mutex` or confinement |
| C# | `async void`; sync-over-async deadlocks; `ConfigureAwait` context assumptions |
| Swift concurrency | Actor reentrancy: state checked before an `await` may change before the code resumes; non-Sendable values crossing isolation domains |
| Rust | `Send`/`Sync` prevents data races in safe code, but logical races and deadlocks (holding a `Mutex` guard across `.await`) remain |

## Reading dumps

- **Java thread dump:** look for `BLOCKED (on object monitor)` with `waiting to lock <0x...>` and the thread that `locked <0x...>`; the JVM often reports "Found one Java-level deadlock".
- **Go goroutine dump:** many goroutines in `chan receive` or `semacquire` on the same address; `sync.(*Mutex).Lock` stacks.
- **Python:** `py-spy dump` shows each thread's stack; GIL contention appears as threads waiting in C calls.

## Reproduction techniques

- Barriers or latches to start threads at the same moment.
- Many iterations with more threads than cores.
- Race detectors: Go `-race`, ThreadSanitizer (`-fsanitize=thread`) for C/C++/Rust/Swift.
- Model checking or exhaustive interleaving tools: jcstress (JVM), Loom (Rust).
- Test-only delay injection at the suspected window to force the interleaving; remove from production code.
