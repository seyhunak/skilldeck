# Smell to refactoring map

Names follow Martin Fowler's *Refactoring* (2nd edition) catalogue where possible. Choose the smallest refactoring that unblocks the goal; several rows often apply at once.

| Smell | Signs in code | First refactorings to try | Watch out for |
|---|---|---|---|
| Long function | Scrolls past a screen, comment headers between blocks | Extract Function, Replace Temp with Query, Split Phase | Extracted functions that need many parameters indicate a missing object |
| Large class | Many fields used by disjoint subsets of methods | Extract Class, Extract Superclass only if a true is-a relation exists | Moving methods breaks reflection-based frameworks |
| Long parameter list | Five or more parameters, flags among them | Introduce Parameter Object, Remove Flag Argument, Preserve Whole Object | Public API change: use parallel change |
| Feature envy | Method mostly reads another object's data | Move Function, Extract Function then Move | Circular dependencies after the move |
| Data clumps | Same three fields travel together | Introduce Parameter Object, Extract Class | Serialization formats that depend on flat fields |
| Primitive obsession | Strings for money, IDs, statuses | Replace Primitive with Object, Replace Type Code with Subclasses | Equality and hashing semantics of the new type |
| Repeated switch on type | Same `switch`/`if` chain in several places | Replace Conditional with Polymorphism, or a lookup table | Over-engineering when there is only one switch |
| Nested conditionals | Arrow-shaped code, deep indentation | Replace Nested Conditional with Guard Clauses, Decompose Conditional, Consolidate Conditional Expression | Short-circuit evaluation order with side effects |
| Duplicated code | Copy-pasted blocks with small variations | Extract Function, Slide Statements to align, Parameterize Function | Duplicates that are only coincidentally similar and will diverge |
| Divergent change | One module changes for many unrelated reasons | Split Phase, Extract Class by reason for change | — |
| Shotgun surgery | One change touches many files | Move Function, Combine Functions into Class, Inline Class | — |
| Global data / hidden dependencies | Singletons, static calls, direct clock or I/O | Encapsulate Variable, introduce a parameter or constructor-injected dependency | Initialization order changes |
| Mutable data shared widely | Many writers to the same structure | Encapsulate Record, Separate Query from Modifier, Change Reference to Value | Aliasing bugs revealed by the change |
| Speculative generality | Unused hooks, abstract classes with one subclass | Collapse Hierarchy, Inline Function, Remove Dead Code | Code used via reflection or configuration |
| Message chains | `a.b().c().d()` | Hide Delegate, Extract Function | Creating middle-man classes |

## Seams for untested code

From Michael Feathers' *Working Effectively with Legacy Code*:

- **Parameterize Constructor / Method** — pass in the dependency that was created internally.
- **Extract Interface** — let a test supply a fake.
- **Subclass and Override Method** — override the awkward call in a test subclass (a temporary seam).
- **Wrap Method / Wrap Class** — add new behaviour around old code without editing its body.
- **Sprout Method / Sprout Class** — write new logic in a fresh, tested unit and call it from the old code.

## Step-size rule of thumb

If a step cannot be described in one short sentence naming one refactoring, or its diff is too large to read in a couple of minutes, split it. This is a heuristic, not a rule; adjust to the team's review habits.
