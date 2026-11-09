# Write Tests for a Function

## Intended task
Use this prompt to get a thorough, idiomatic test suite for one function or method in a specific test framework. Instead of asking for "some tests", it makes the model derive the function's contract, partition the input space, pick boundary values, decide what to fake, and only then write code. It also makes the model report behaviour that looks wrong instead of silently encoding it in an assertion. For deciding what to test across a whole system, use `test-strategy-agent`; for the underlying technique, see the `unit-test-design` skill.

## Required context
- **The function source** and its signature, including types.
- **Test framework and version** (pytest, Jest, Vitest, JUnit 5, Go `testing`, XCTest, RSpec) and any assertion or mocking library already in use.
- **Intended behaviour**: docstring, ticket text or a few sentences. Without a stated contract, the model can only test what the code currently does.
- **Dependencies** the function calls (clock, random, network, database, filesystem) and how the project fakes them today.
- Optional: an existing test file from the repo so the output matches local conventions (fixtures, naming, helpers).

## Prompt
```text
You are a senior engineer who writes tests that catch real regressions, not tests that restate the implementation. Write a test suite for the function below.

Language and test framework: {{TEST_FRAMEWORK}}
Function under test:
{{FUNCTION_SOURCE}}

Intended behaviour (the contract, from docs or ticket):
{{INTENDED_BEHAVIOUR}}

Collaborators and side effects (clock, I/O, network, DB, randomness) and how this project fakes them:
{{DEPENDENCIES}}

Existing test conventions to follow (example test file or notes):
{{PROJECT_CONVENTIONS}}

Work in this order and show each stage:
1. Contract: list preconditions, postconditions, invariants, and every error the function can raise or return. Mark anything inferred from code rather than the stated contract with "Inferred:".
2. Test design table: equivalence classes for each input, boundary values (empty, one, many, min, max, off-by-one, zero, negative, unicode, null/None where the type allows), error cases, and state-dependent cases. One row per planned test with the expected result and why it matters.
3. Doubles: decide what to fake, stub or leave real. Prefer real objects for pure collaborators; fake only non-deterministic or slow boundaries. Never mock the function under test.
4. Tests: write complete, runnable code in {{TEST_FRAMEWORK}} following Arrange-Act-Assert, one behaviour per test, descriptive names stating the scenario and expectation. Use parametrised/table-driven tests for partitions. Make time and randomness deterministic.
5. Property or invariant tests: if the function has a natural property (round-trip, idempotence, ordering, conservation), add one property-based test using {{PROPERTY_LIBRARY}} or explain why none applies.
6. Suspected bugs: list any case where the code disagrees with the contract. Write that test asserting the contract and mark it as expected to fail, rather than asserting the buggy behaviour.
7. Gaps: what remains untested and why (needs integration test, unclear contract, unreachable branch).

Do not claim the tests pass; you have not run them.
```

## Variables
| Variable | Description | Required |
|---|---|---|
| `{{TEST_FRAMEWORK}}` | Language plus framework, e.g. "TypeScript, Vitest 2" | Yes |
| `{{FUNCTION_SOURCE}}` | Full source of the function and any small helpers it uses | Yes |
| `{{INTENDED_BEHAVIOUR}}` | Docstring, ticket text or plain description of what it should do | Yes |
| `{{DEPENDENCIES}}` | Collaborators and side effects, plus how the project fakes them | Yes |
| `{{PROJECT_CONVENTIONS}}` | An existing test file or notes on fixtures and naming; "none" if absent | No |
| `{{PROPERTY_LIBRARY}}` | e.g. Hypothesis, fast-check, jqwik, or "none available" | No |

## Output format
Seven labelled stages. Stage 2 is a Markdown table with columns `Case | Input | Expected | Rationale`. Stage 4 is a single fenced code block containing the whole test file with imports, ready to save. Stage 6 lists each suspected bug with the input, the contract expectation, and the observed code behaviour. Keep prose short; the table and the code carry the value.

## Example usage
For a Python `parse_duration("1h30m") -> timedelta` with pytest and Hypothesis, a good answer partitions inputs into single units, combined units, whitespace, empty string, unknown units, overflow and negative values; parametrises the valid cases; asserts `ValueError` messages for invalid ones; and adds a round-trip property `parse_duration(format_duration(td)) == td` for whole-second durations. It flags as a suspected bug that `"90m"` and `"1h30m"` are accepted but `"1h90m"` is also silently accepted, and asks whether that is intended.

## Customization
- For legacy code without a contract, replace stage 6 with "characterization tests" that pin current behaviour, and say so in the test names.
- For UI components, swap partitions for states (loading, empty, error, populated) and interactions.
- Add a line limiting the suite size (for example "at most 15 tests") if the output is too broad.
- Remove stage 5 if your stack has no property-testing library.
