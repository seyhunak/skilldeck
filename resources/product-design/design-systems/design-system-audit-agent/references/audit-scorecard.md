# Design System Audit Scorecard

## Maturity scale (per dimension)

| Score | Label | Meaning |
|---|---|---|
| 1 | Ad hoc | Exists informally; values and patterns live in individual files or teams |
| 2 | Defined | Documented and shared, but inconsistently applied and lightly governed |
| 3 | Managed | Consistently structured, versioned, owned, and used by most teams |
| 4 | Optimized | Measured, evolved from feedback, adoption tracked, quality gates in place |

## Dimension evidence prompts

| Dimension | Score 2 looks like | Score 4 looks like |
|---|---|---|
| Tokens | Color and type values listed in a style guide | Primitive, semantic, and component tiers; themes generated from one source; no raw values in components |
| Components | Core inputs and buttons exist | Full state coverage, consistent APIs, design and code parity |
| Consistency | Similar components behave similarly most of the time | Shared naming conventions and composition patterns enforced in review |
| Accessibility | Some contrast checks done | Accessibility criteria in definition of done; shared components tested with assistive technology |
| Documentation | Property tables exist | Usage guidance, do and don't examples, accessibility and content notes, kept in sync with releases |
| Governance | A named owner | Contribution model, versioning, release notes, deprecation policy, intake and support SLAs |
| Adoption | Some teams use the library | Adoption measured per product area; drift tracked and reduced over time |

## Per-component completeness checklist

- [ ] Variants and sizes documented, each with a stated purpose
- [ ] States designed: default, hover, focus-visible, active, disabled, loading, error, selected (as applicable)
- [ ] Uses semantic tokens only; no raw color, spacing, or type values
- [ ] Text and non-text contrast meet WCAG 2.2 AA in every theme
- [ ] Target size meets at least 24 by 24 CSS pixels (WCAG 2.2 criterion 2.5.8) or spacing exception
- [ ] Keyboard interaction and focus order specified
- [ ] Content guidance: label length, truncation, localization expansion
- [ ] Responsive behavior and density variants specified
- [ ] Design and code property names match
- [ ] Usage guidance includes when not to use it and the alternative

## Drift measurement notes

- State the population: which repositories, which product areas, which date.
- Count instances, not files, when measuring local clones.
- Report ratios with denominators, for example "17 of 64 sampled modals".
- Re-run the same method in later audits so trends are comparable.
