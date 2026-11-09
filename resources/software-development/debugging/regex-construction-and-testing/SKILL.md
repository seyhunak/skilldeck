---
name: regex-construction-and-testing
description: Builds, explains, and tests regular expressions for a named engine (PCRE, Python re, JavaScript, Java, Go RE2, .NET, POSIX grep/sed), with a positive and negative test table, anchoring, and checks for catastrophic backtracking (ReDoS). Use when writing or debugging a regex, reviewing one for correctness or denial-of-service risk, or deciding whether a regex is the wrong tool.
---

# Regex Construction and Testing

Regular expressions fail in two characteristic ways: they match too much or too little because nobody wrote down the cases, and they hang on adversarial input because of nested quantifiers. This skill writes the test cases before the pattern, builds the pattern for a specific engine, and checks it for backtracking risk.

## When to use

- Writing a pattern for validation, extraction, search-and-replace, or log parsing.
- Explaining or fixing an existing regex that misbehaves.
- Reviewing regexes that run on untrusted input (request validation, WAF rules, log processors) for ReDoS.

Not for: parsing nested or recursive structures such as HTML, JSON, or programming languages (use a real parser), or full email/URL validation where a library or a send-a-confirmation check is more reliable.

## Inputs

- What to match and what must not match, ideally with real samples.
- Target engine and flags (case-insensitive, multiline, dotall, Unicode). Syntax and features differ: lookbehind support, possessive quantifiers, named group syntax (`(?P<name>...)` in Python vs `(?<name>...)` elsewhere), `\d` matching non-ASCII digits in Unicode modes.
- Whether input is trusted, and its maximum length.

## Procedure

1. **Write the test table first.** At least five strings that must match and five that must not, including edge cases: empty string, leading/trailing whitespace, maximum length, Unicode characters, near-misses that differ by one character, and multiline input if relevant. For extraction, specify the expected captured groups.

2. **Decide full match vs search.** Validation needs anchoring: `^...$` in most engines, but `$` may match before a final newline (Python, PCRE); prefer `\A...\z` (PCRE, Ruby, Java), `\A...\Z` in Python, or the API that forces a full match (`re.fullmatch`, Java `matches()`). JavaScript has no `\A`/`\z`; use `^...$` without the `m` flag.

3. **Build incrementally from specific pieces.** Prefer explicit character classes over `.`: `[0-9]` or `\d` with known Unicode semantics, `[A-Za-z0-9._%+-]`, negated classes like `[^"]*` for "anything up to the quote". Use non-capturing groups `(?:...)` unless you need the capture; name the captures you keep. Make quantifiers bounded where the domain allows (`\d{1,5}` instead of `\d+`).

4. **Control greediness deliberately.** `.*` grabs as much as possible and backtracks; `.*?` grabs as little as possible. A negated class (`"[^"]*"`) is usually clearer and faster than a lazy dot (`".*?"`).

5. **Check for catastrophic backtracking.** Red flags in backtracking engines (PCRE, Python, JavaScript, Java, .NET, Ruby):
   - Nested quantifiers over the same characters: `(a+)+`, `(\w*)*`, `(.*,)*`.
   - Alternation with overlapping branches inside a quantifier: `(a|aa)+`, `(\w|\d)+`.
   - Adjacent quantified tokens that can match the same text: `\s*\s*`, `\d+\d+`.
   Test with an adversarial string that almost matches, e.g. `"a" * 30 + "!"` against `^(a+)+$`, and time it. Remedies: remove ambiguity (make each character matchable in only one way), use possessive quantifiers or atomic groups (`a++`, `(?>...)`) where supported, cap input length, set a timeout (.NET `Regex` match timeout), or use a linear-time engine (RE2, Go `regexp`, Rust `regex`) — these do not support backreferences or lookaround.

6. **Run the test table.** Execute in the target language, not just an online tester whose flavour may differ:
   ```python
   import re
   pat = re.compile(r"\A(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)\Z")
   good = ["0.0.0", "1.2.3", "10.20.30"]
   bad = ["01.2.3", "1.2", "1.2.3.4", "v1.2.3", "1.2.3\n", ""]
   assert all(pat.match(s) for s in good)
   assert not any(pat.match(s) for s in bad)
   ```
   For grep/sed, remember basic vs extended syntax (`grep -E`, `sed -E`) and that POSIX classes like `[[:digit:]]` are the portable form.

7. **Explain the final pattern.** Break it into tokens with a one-line meaning each, or use verbose mode (`re.VERBOSE`, `(?x)`) with inline comments for patterns that will be maintained.

## Expected output

```markdown
### Pattern (engine: Python 3 re, flags: none)
    \A(?P<major>0|[1-9]\d*)\.(?P<minor>0|[1-9]\d*)\.(?P<patch>0|[1-9]\d*)\Z
### Explanation
| Token | Meaning |
### Test table
| Input | Expected | Actual | Groups |
### Backtracking review
<ambiguity analysis; adversarial input tried; timing>
### Caveats
<engine differences, Unicode behaviour, what it intentionally does not cover>
```

## Constraints and limitations

- Always name the engine; a pattern correct in PCRE may fail or behave differently in JavaScript or RE2.
- Do not claim a pattern is ReDoS-safe based on reading alone when it contains nested or overlapping quantifiers; test it or rewrite it unambiguously.
- For security validation, prefer allow-lists with strict anchors, and pair regex checks with length limits.
- When the honest answer is "use a parser or library", say so.

## Examples

**Request:** "Match log lines like `2026-11-09T10:15:00Z ERROR [payments] timeout after 3000ms` and extract level, component, and duration."
**Pattern (Python):** `^(?P<ts>\S+) (?P<level>[A-Z]+) \[(?P<component>[^\]]+)\] .*?(?P<ms>\d+)ms$` with tests for a line without a duration (must not match), a component containing a hyphen, and a message with two numbers (captures the last `\d+ms`). The `.*?` before the duration is followed by a required literal `ms` and end anchor, and the line length is bounded by the logger, so backtracking risk is low; this was confirmed by timing a 10,000-character line.
