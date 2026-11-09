---
name: stack-trace-analysis
description: Reads stack traces and crash reports across Java/Kotlin, Python, JavaScript/Node, Go, .NET, Rust, and Swift/Objective-C - finds the first relevant frame, follows chained causes, recognises common failure signatures, and symbolicates native and minified traces. Use when given an exception, panic, or crash log and asked what went wrong and where to look.
---

# Stack Trace Analysis

A stack trace is a precise record of where execution was when something failed, but it is easy to misread: the top frame is often library code, the real cause may be three "Caused by" levels down, and native or minified traces are meaningless until symbolicated. This skill reads traces systematically and turns them into a located, testable hypothesis.

## When to use

- An exception, panic, segfault, or crash report needs explaining.
- A bug report or log contains a trace and you need the responsible code location.
- Native crash logs (iOS/macOS `.ips`, Android tombstones) or minified JS traces need symbolication.

Not for: ranking hypotheses for a vague error message without a trace (`debug-error-message-prompt`), live incident triage across metrics and logs (`production-incident-debugger-agent`), or races and deadlocks (`concurrency-bug-analysis-agent`).

## Inputs

- The complete trace, untruncated, including all `Caused by` / chained sections and thread dumps if present.
- Language, runtime version, and the app version or commit that produced it.
- Access to source at that version, and for native/minified traces the matching symbol files (dSYM, ProGuard/R8 `mapping.txt`, source maps, PDBs).

## Procedure

1. **Orient to the format.** Frame order differs:
   - **Java/Kotlin/.NET:** innermost frame first; read `Caused by:` chains to the last one — the root cause is usually at the bottom. `... 12 more` means frames shared with the enclosing trace.
   - **Python:** innermost frame *last* ("most recent call last"). "During handling of the above exception, another exception occurred" vs "The above exception was the direct cause" distinguishes accidental from explicit chaining.
   - **JavaScript/Node:** innermost first; async frames may be missing unless the runtime records async stack traces; `at async` frames help.
   - **Go:** panic message, then goroutine stacks; the panicking goroutine is listed first with `[running]`. Each frame shows function then `file:line +offset`.
   - **Rust:** set `RUST_BACKTRACE=1`; skip `std::panicking` and `core::` frames.
   - **Apple crash reports:** exception type and codes, then the crashed thread's backtrace; frames show binary image and address.

2. **Read the exception type and message literally.** They often state the cause outright: the key that was missing, the index and length, the null receiver, the file path. Note any values in the message.

3. **Find the first frame in your code.** Skip runtime, framework, and third-party frames (filter by package or module prefix: `com.yourco.`, your repo paths). That frame is where your code handed bad state onward or made the bad call; the actual defect may be in its callers, so read one or two frames further out too.

4. **Match a known signature.** Common ones:
   - `NullPointerException` / `TypeError: Cannot read properties of undefined` / `AttributeError: 'NoneType'` / `nil pointer dereference` / `EXC_BAD_ACCESS (SIGSEGV)` at a low address — a missing value; trace where it should have been set.
   - `IndexError` / `ArrayIndexOutOfBounds` / `index out of range [5] with length 5` — boundary or empty-collection case.
   - `ConcurrentModificationException`, `fatal error: concurrent map writes` — mutation during iteration or unsynchronised sharing.
   - `StackOverflowError` / `RecursionError` — look for the repeating frame cycle.
   - `OutOfMemoryError`, `SIGKILL` with memory pressure / `EXC_RESOURCE` — the trace shows the victim, not necessarily the allocator; need heap evidence.
   - `EXC_CRASH (SIGABRT)` — an assertion, uncaught Objective-C/Swift error, or `fatalError`; look at the "Last Exception Backtrace" or the line just before abort.
   - `ClassNotFoundException`, `ModuleNotFoundError`, `dyld: Library not loaded` — packaging or environment, not logic.

5. **Symbolicate when frames are addresses or minified.**
   - iOS/macOS: match the binary's UUID to the dSYM (`dwarfdump --uuid`), then `atos -arch arm64 -o App.dSYM/Contents/Resources/DWARF/App -l <load address> <addresses>`; Xcode Organizer does this for uploaded builds.
   - Android: `retrace` with the R8/ProGuard `mapping.txt` for that exact build; native frames via `ndk-stack -sym <obj dir>`.
   - JavaScript: apply the matching source map (browser devtools, your error tracker, or the `source-map` library).
   - Mismatched symbol files silently produce wrong lines; verify build ids before trusting the output.

6. **Reconstruct the state.** Read the source at the reported version for the key frames. Ask: what input or state makes this line fail? Which caller could have supplied it? Check recent changes to those files (`git log -L` or `git log -p -- file`).

7. **Form and test a hypothesis.** State it as a falsifiable claim ("`order.customer` is null when guest checkout is used, because...") and propose the smallest reproduction or test to confirm it before suggesting a fix.

## Expected output

```markdown
### Summary
<one sentence: what failed and where>
### Key frames
| Role | Frame | File:line |
| Failure point | ... | ... |
| First app frame | ... | ... |
| Likely origin | ... | ... |
### Root cause hypothesis
<claim> — confidence: high/medium/low — evidence: <message values, frames, code read>
### How to confirm
<repro steps or test>
### Suggested fix
<only after the hypothesis is supported>
### Missing information
<symbols, other threads, version>
```

## Constraints and limitations

- Do not guess line contents you have not read at the matching version; line numbers shift between releases.
- A trace shows one moment; intermittent failures may need logs, thread dumps, or multiple traces.
- Traces can contain user data, tokens in URLs, or file paths; redact before quoting them back or sharing.
- Memory corruption in native code often crashes far from the bug; recommend sanitizers (ASan, TSan) or Zombies rather than over-trusting the crash frame.

## Examples

```text
Traceback (most recent call last):
  File "app/api/orders.py", line 57, in create_order
    total = pricing.compute(cart)
  File "app/pricing.py", line 23, in compute
    rate = TAX_RATES[cart.region]
KeyError: 'XK'
```

**Analysis:** failure point and first app frame are both `app/pricing.py:23`; the message names the missing key `XK`. Hypothesis (high confidence): the tax table lacks a region the checkout accepts. Confirm with a test calling `compute` for a cart in region `XK`. Fix options: validate region at the API boundary with a 422, or add the region with an explicit rate — a product decision, so ask.
