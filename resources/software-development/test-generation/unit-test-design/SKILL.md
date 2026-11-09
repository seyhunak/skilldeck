---
name: unit-test-design
description: Designs unit test cases systematically using equivalence partitioning, boundary value analysis, decision tables, and state-transition coverage, chooses appropriate test doubles, and structures tests as Arrange-Act-Assert. Use when writing tests for a function or class, reviewing whether existing unit tests are adequate, or deciding what to mock.
---

# Unit Test Design

Good unit tests come from deliberate case selection, not from mirroring the implementation. This skill derives a minimal, high-value set of cases from the specification of a unit, decides where test doubles belong, and writes tests that fail for one reason and read like documentation.

## When to use

- Writing tests for a new or untested function, method, or class.
- Reviewing a test file and asking "what is missing?".
- Deciding whether to use a fake, stub, mock, or the real collaborator.

Not for: whole-system test strategy and pyramid balance (`test-strategy-agent`), intermittent failures (`flaky-test-diagnosis`), or quick generation in a specific framework from a code snippet (`write-tests-for-function-prompt`).

## Inputs

- The unit's code and, ideally, its contract: docstring, type signature, requirements, or bug report.
- Test framework and language conventions (pytest, JUnit 5, Jest/Vitest, XCTest, Go `testing`).
- Collaborators the unit calls (database, clock, HTTP client, random source, filesystem).

## Procedure

1. **State the contract.** Write down inputs, outputs, side effects, and error behaviour in plain sentences. Where the contract is ambiguous, list the ambiguity as a question; tests should not silently encode a guess.

2. **Partition the input space (equivalence classes).** For each input, list valid and invalid classes. Example for `discount(age: int)`: invalid negative; child 0-12; adult 13-64; senior 65+; invalid non-integer if the language allows it. One representative per class is usually enough.

3. **Add boundary values.** For each ordered boundary test the value on, just below, and just above: 12, 13, 64, 65, plus 0 and the type's limits if relevant. Also test empty collections, single-element collections, maximum sizes, empty strings, Unicode and whitespace-only strings, and null/None where the type allows it.

4. **Handle combinations deliberately.** When outputs depend on several conditions, build a decision table (one column per rule) and write one test per column rather than the full cross-product. For many independent parameters, pairwise selection covers every pair of values with far fewer cases. For stateful objects, draw the state machine and cover each valid transition plus at least one invalid transition per state.

5. **Choose test doubles by what the collaborator is.**
   - **Stub** — returns canned values for queries (e.g. a clock returning a fixed instant).
   - **Fake** — a working lightweight implementation (in-memory repository). Prefer for stateful collaborators; tests stay behaviour-focused.
   - **Mock/spy** — verify an outgoing command was issued (email sent, event published). Use only when the interaction is the observable behaviour.
   - **Real object** — for value objects and pure functions; never mock what you own and is cheap.
   Inject time, randomness, and IDs; never call the real clock or network from a unit test. Over-mocking is a smell: if a test asserts on five mock calls, it is testing implementation.

6. **Write each test as Arrange-Act-Assert.** One behaviour per test, a single act line, assertions on outcomes rather than internals. Name tests as behaviour: `test_senior_discount_applies_from_65` or `rejects_negative_age`. Use parameterised tests for classes and boundaries to avoid copy-paste.

7. **Assert precisely.** Compare full values where practical, check exception type and message fragment, and assert that side effects did not happen in negative cases. Avoid asserting on log text unless logging is the contract.

8. **Check the suite's power.** Mutate the code mentally (or with a mutation tool such as PIT, mutmut, or Stryker): flip `<` to `<=`, drop a branch, return early. If no test fails, a case is missing. Line coverage is a floor, not evidence of adequacy.

## Expected output

```markdown
### Contract
<inputs, outputs, side effects, errors; open questions>
### Case matrix
| # | Technique | Input(s) | Expected | Notes |
|---|-----------|----------|----------|-------|
### Test doubles
| Collaborator | Double type | Reason |
### Tests
<framework code, AAA structure, parameterised where possible>
### Gaps and questions
```

## Constraints and limitations

- Do not change production code to make it testable without saying so; propose the seam (inject clock, extract pure function) separately.
- Tests must be deterministic and independent of execution order and wall-clock time.
- When the contract is unknown, characterisation tests (asserting current behaviour) are acceptable, but label them as such.
- Keep unit tests fast (milliseconds); anything needing a real database or network belongs in integration tests.

## Examples

**Unit:** `parse_duration("1h30m") -> seconds`.
**Classes:** single unit (`45s`), combined units (`1h30m`), zero (`0s`), missing unit (`90`), unknown unit (`5x`), empty string, negative (`-5m`), whitespace (`" 5m "`), overflow-sized hours.
**Boundaries:** `59s`, `60s` (does it normalise?), largest supported value.
**Doubles:** none — pure function, so no mocks.
**Test shape (pytest):**

```python
@pytest.mark.parametrize("text,expected", [("45s", 45), ("1h30m", 5400), ("0s", 0)])
def test_parses_valid_durations(text, expected):
    assert parse_duration(text) == expected

@pytest.mark.parametrize("text", ["", "90", "5x", "-5m"])
def test_rejects_invalid_durations(text):
    with pytest.raises(ValueError):
        parse_duration(text)
```

The whitespace case is listed as an open question until the contract says whether it is trimmed.
