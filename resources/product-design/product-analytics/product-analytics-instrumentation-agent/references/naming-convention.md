# Event Naming Convention

A single convention, applied everywhere, matters more than which convention you choose. The defaults below are widely used in product analytics; adapt them once and document the decision.

## Events

- Pattern: **Object Action**, Title Case, past tense: `Account Created`, `Invite Sent`, `Plan Upgraded`, `Search Performed`.
- Object is a noun from the product's domain language; action is a past-tense verb describing a completed state change.
- One event per meaningful action. Use properties for variations: `File Exported` with `format`, not `CSV Exported` and `PDF Exported`.
- Views are events only when a question needs them: `Checkout Step Viewed` with `step_name`, not one event per page.
- Avoid UI-specific names that break on redesign: prefer `Filter Applied` over `Blue Filter Button Clicked`.

## Properties

- `snake_case`, lowercase, singular nouns: `plan_tier`, `item_count`, `payment_method`.
- Booleans start with `is_` or `has_`: `is_trial`, `has_custom_domain`.
- Units in the name where ambiguous: `duration_ms`, `amount_minor_units` (with a separate `currency` property).
- Enumerations list allowed values in the tracking plan; values are lowercase snake_case: `card`, `bank_transfer`.
- Timestamps in ISO 8601 UTC; identifiers as strings.

## Anti-patterns

| Anti-pattern | Example | Fix |
|---|---|---|
| Mixed case and tense | `signup`, `UserSignedUp`, `Sign Up Completed` | One event: `Account Created` |
| Values in event names | `Plan Upgraded To Pro` | `Plan Upgraded` with `new_plan: pro` |
| Free text where an enum fits | `reason: "too expensive!!"` | `reason: price` plus optional moderated text stored elsewhere |
| Personal data in properties | `email`, `full_name` | Use a pseudonymous user id; join in the warehouse under access control |
| Platform-specific duplicates | `iOS Purchase`, `Web Purchase` | `Order Completed` with `platform` |

## Review questions for every new event

1. Which question or metric needs it?
2. Does an existing event with a new property already cover it?
3. Is the trigger moment defined precisely enough to implement identically on every platform?
4. Does any property contain personal or sensitive data?
5. Who owns it, and when should it be reviewed for deprecation?
