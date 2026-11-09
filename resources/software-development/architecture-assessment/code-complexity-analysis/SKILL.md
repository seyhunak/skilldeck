---
name: code-complexity-analysis
description: Measures and interprets code complexity - cyclomatic and cognitive complexity, nesting depth, function size, and coupling metrics (afferent/efferent coupling, instability, abstractness, dependency cycles) - with standard tools, and turns the numbers into a prioritised list of refactoring targets. Use when assessing maintainability, choosing what to refactor, or setting complexity gates in CI.
---

# Code Complexity Analysis

Complexity metrics are useful only when interpreted: a function with cyclomatic complexity 25 that has not changed in four years and is fully tested is less urgent than a function of 12 that changes weekly and has no tests. This skill measures the right things with established tools and combines them with context to recommend where effort pays off.

## When to use

- Assessing maintainability of a module or codebase.
- Choosing refactoring targets or justifying a refactoring budget.
- Setting or tuning complexity thresholds in linters and CI.
- Investigating why a component is hard to change (coupling, cycles).

Not for: change-frequency and ownership data from version history (`git-history-forensics`, which complements this skill), behaviour-preserving refactoring itself (`code-refactoring-agent`), or a debt register with cost estimates (`technical-debt-assessment-agent`).

## Inputs

- Source code and language(s).
- Scope: whole repo, a package, or a list of files.
- Optional: churn data, test coverage report, existing lint configuration.

## Procedure

1. **Choose tools for the language.** Examples: `lizard` (many languages: CCN, NLOC, parameter count), `radon cc -s -a` and `radon mi` (Python), ESLint `complexity` and `max-depth` rules, `eslint-plugin-sonarjs` `cognitive-complexity` (JS/TS), `gocyclo` and `gocognit` (Go), PMD or Checkstyle (Java), SwiftLint `cyclomatic_complexity` (Swift), SonarQube for cross-language cognitive complexity. For coupling: `dependency-cruiser` or `madge --circular` (JS/TS), `pydeps` or `import-linter` (Python), JDepend or ArchUnit (Java), `go list -deps`/`goda` (Go).

2. **Measure function-level complexity.**
   - **Cyclomatic complexity** (McCabe): number of linearly independent paths ≈ decision points + 1. It is a lower bound on the test cases needed for branch coverage. Commonly cited thresholds: 1-10 simple, 11-20 moderate, 21-50 complex, over 50 very hard to test — treat as heuristics; tools default differently (ESLint's `complexity` defaults to 20, lizard warns at 15).
   - **Cognitive complexity** (SonarSource): increments for breaks in linear flow and adds a penalty for nesting; better reflects how hard code is to read. SonarQube's default function threshold is 15.
   - **Size and shape:** lines per function, parameters (more than about 4-5 suggests a missing parameter object), maximum nesting depth (over 3-4 is a readability problem).

3. **Measure module-level coupling.** For each package or module:
   - **Ca** (afferent coupling): how many other modules depend on it.
   - **Ce** (efferent coupling): how many modules it depends on.
   - **Instability I = Ce / (Ca + Ce)**, from 0 (stable, many dependants) to 1 (unstable).
   - **Abstractness A** = abstract types / total types; **distance from the main sequence D = |A + I - 1|** (Robert C. Martin). High D near (0,0) — concrete and heavily depended on — is the "zone of pain"; near (1,1) — abstract and unused — is the "zone of uselessness".
   - **Cycles:** any dependency cycle between packages is a structural smell; list each cycle explicitly.

4. **Add context before ranking.** Join metrics with change frequency (from `git-history-forensics`), test coverage, and defect history if available. The priority signal is complexity x churn: complex code that changes often is where defects and slowdowns concentrate. Stable complex code may be best left alone.

5. **Look behind the numbers.** Read the top items. High cyclomatic complexity from a flat `switch` over 20 enum cases is often fine; deeply nested conditionals with mixed concerns are not. Generated code, parsers, and state machines may legitimately score high — exclude or annotate them.

6. **Recommend specific remedies.** Map pattern to refactoring: long nested conditionals → guard clauses, extract function, decompose conditional; type-switches repeated in many places → polymorphism or a lookup table; long parameter lists → parameter object; god module with high Ce → split by responsibility; cycles → dependency inversion or moving the shared abstraction to a lower layer.

7. **Propose gates sensibly.** Ratchet rather than enforce a big-bang threshold: fail CI only on new or worsened violations (baseline file, "new code" conditions in SonarQube), and tighten as hotspots are refactored.

## Expected output

```markdown
### Scope and tools
<paths, tools and versions, exclusions>
### Function hotspots
| Function | File | Cyclomatic | Cognitive | NLOC | Max nesting | Churn (12m) | Covered? | Priority |
### Module coupling
| Module | Ca | Ce | I | A | D | In cycle? |
### Dependency cycles
<A -> B -> C -> A>
### Interpretation
<what the numbers mean here; false positives excluded>
### Recommendations
| Target | Problem pattern | Refactoring | Expected effect |
### Suggested CI gate
```

## Constraints and limitations

- Report tool output faithfully; do not estimate metric values you did not compute. If you can only read code, label counts as manual estimates.
- Metrics differ across tools in how they count (e.g. `&&`/`||`, `switch` cases); state the tool used.
- Low complexity is not proof of good design, and high scores are not proof of bad design.
- Abstractness is meaningful mainly in languages with explicit interfaces or abstract classes.

## Examples

**Finding:** `checkout/validate.ts::validateCart` — cyclomatic 31, cognitive 48, nesting depth 6, 42 commits in 12 months, 38% branch coverage.
**Interpretation:** top priority; it is both hard to read and constantly edited, with weak tests.
**Recommendation:** add characterisation tests first, then extract per-rule validators behind a common interface and replace the nested `if` ladder with a list of rules evaluated in order. Expected effect: each rule independently testable, cyclomatic per function under 10.
