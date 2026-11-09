---
name: accessibility-design-review
description: Review mockups, prototypes, and design specs against the WCAG 2.2 Level AA criteria that are decided at design time - text and non-text contrast, use of color, target size, focus visibility and state design, reading and focus order, text alternatives, reflow and text resizing, motion, and form labels and errors. Use before handoff to engineering, when creating or updating components, or when a design needs accessibility annotations.
---

# Accessibility Design Review

Many accessibility defects are created in design files: low-contrast palettes, tiny targets, missing focus states, meaning carried only by color, and error designs that leave screen-reader users guessing. Catching them before build is far cheaper than after. This skill covers what a designer controls; code semantics and assistive-technology behavior must still be tested on the built product.

## When to use

- Before design handoff for a new feature or flow.
- When creating or changing design system tokens or components.
- When a design needs accessibility annotations for engineers (headings, focus order, labels, alternative text).
- When an audit found defects and the team wants to fix the source designs.

Not for: auditing implemented code, ARIA usage, or screen-reader behavior (use a code-level review such as `frontend-accessibility-review-agent`), or issuing a conformance claim or legal opinion.

## Inputs

- Designs: frames, screenshots, or prototype descriptions, including color values (hex or RGB) where possible. Required.
- Target conformance level (default WCAG 2.2 AA) and platforms (web, iOS, Android). Recommended.
- Component states and interaction specs if available. Optional.

## Procedure

1. **Text contrast (WCAG 1.4.3).** For each text and background pair compute the contrast ratio. Relative luminance L = 0.2126 R + 0.7152 G + 0.0722 B, where each sRGB channel c (0-1) is linearized as c/12.92 if c is at or below 0.04045, else ((c + 0.055)/1.055)^2.4. Ratio = (L_lighter + 0.05) / (L_darker + 0.05). Minimum 4.5:1 for normal text and 3:1 for large text (at least 18 point regular or 14 point bold, roughly 24 px or 18.66 px bold). Check text over images and gradients at the worst point, and check placeholder and disabled-looking text that still conveys information.
2. **Non-text contrast (1.4.11).** Visual boundaries needed to identify controls (input borders, checkbox outlines, toggle tracks), focus indicators, and meaningful graphics such as chart lines need 3:1 against adjacent colors.
3. **Use of color (1.4.1).** Color must not be the only way to convey information: errors, required fields, link text within paragraphs, status, and chart series need a second cue (icon, text, underline, pattern).
4. **Target size (2.5.8).** Pointer targets are at least 24 by 24 CSS pixels, or have enough spacing that a 24 px circle centered on each does not overlap another target; inline links in text are exempt. Platform guidelines recommend larger touch targets (Apple suggests 44 by 44 points, Material suggests 48 by 48 dp); note them as best practice.
5. **Focus and states (2.4.7, 2.4.11).** Every interactive component has a designed focus-visible state that meets non-text contrast, and focused elements are not fully hidden by sticky headers, banners, or overlays. Confirm states exist for hover, focus, active, disabled, error, selected, and loading.
6. **Structure and order (1.3.1, 1.3.2, 2.4.3, 2.4.6).** Annotate heading levels, landmarks or regions, and the intended reading and focus order where the visual layout could be ambiguous (multi-column layouts, cards, modals). Headings and labels describe their content.
7. **Text alternatives (1.1.1).** Annotate each image or icon as informative (provide alt text in the spec) or decorative. Icon-only buttons get an accessible name in the annotation.
8. **Resize, reflow, and spacing (1.4.4, 1.4.10, 1.4.12).** Layouts work at 200% text size and reflow at 320 CSS pixels wide without two-dimensional scrolling (except for content such as data tables or maps that requires it), and tolerate increased line, letter, and word spacing without clipping. Avoid fixed-height text containers.
9. **Motion and timing (2.2.2, 2.3.1).** Auto-moving content lasting more than five seconds can be paused; nothing flashes more than three times per second; specify a reduced-motion alternative for large animations as good practice.
10. **Input, labels, and errors (3.3.1, 3.3.2, 3.3.7, 3.3.8, 2.5.7).** Every input has a visible label; required fields and format rules are stated up front; errors are identified in text near the field and summarized for long forms; previously entered information is not requested again in the same process; authentication does not depend on a cognitive test such as memorizing or transcribing without an alternative (allow paste and password managers); any dragging interaction has a single-pointer alternative.
11. **Consistency (3.2.3, 3.2.4, 3.2.6).** Navigation, component identification, and help mechanisms appear consistently across screens.
12. **Write findings and annotations.** For each issue: location, criterion, what fails, measured value where applicable, and a specific fix (for example a darker token that passes). Separate blocking failures from best-practice recommendations.

## Expected output

```markdown
## Accessibility Design Review: <feature> · Target: WCAG 2.2 AA

| # | Screen / component | Criterion | Finding | Measured | Fix | Severity (blocker / should fix / best practice) |
|---|---|---|---|---|---|---|

### Annotations for engineering
- Headings and regions: ...
- Focus order: ...
- Accessible names and alt text: ...
- Error handling: ...

### Not assessable at design stage
- Screen-reader announcements, keyboard traps, ARIA semantics, dynamic updates: verify in build.
```

## Constraints and limitations

- This is a design-stage review, not a conformance audit or certification and not legal advice.
- Contrast must be computed from actual color values; estimates from screenshots can be off due to compression and color profiles.
- Some criteria (keyboard operability, name-role-value, status messages) can only be partly assessed in designs.
- Include people with disabilities in usability testing; expert review cannot substitute for it.

## Examples

Finding: secondary button text #8A8A8A on white #FFFFFF. Linearized channel value for 0x8A (138/255 = 0.541) is about 0.254, so L is about 0.254. Ratio = 1.05 / 0.304, about 3.45:1. Fails 1.4.3 for 14 px regular text (needs 4.5:1). Fix: use #767676 or darker; #767676 on white is about 4.54:1 and passes.

Finding: required fields marked only with red labels. Fails 1.4.1. Fix: add "(required)" text or an asterisk explained at the top of the form, keep the color as a secondary cue.

Finding: icon-only "more" button at 20 by 20 px with 2 px spacing in a table row. Fails 2.5.8. Fix: enlarge the hit area to at least 24 by 24 px (prefer 44) without changing the icon size, and annotate the accessible name "More actions for <row name>".
