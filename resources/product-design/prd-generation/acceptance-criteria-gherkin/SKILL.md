---
name: acceptance-criteria-gherkin
description: Write testable acceptance criteria as Gherkin scenarios (Feature, Background, Scenario, Scenario Outline with Examples, Given/When/Then/And/But) in declarative business language. Covers happy paths, business-rule boundaries, and negative cases. Use when a user story or requirement needs unambiguous, automatable conditions of done for product, engineering, and QA.
---

# Acceptance Criteria in Gherkin

Gherkin is the structured plain-language format used by behaviour-driven development tools such as Cucumber, SpecFlow, and Behave. Its value is a shared, unambiguous description of behavior that stakeholders can read and testers can automate. The most common failure is writing imperative UI scripts ("click", "type", "scroll") instead of declarative behavior.

## When to use

- A story or requirement is ready for refinement and needs conditions of done.
- Product, engineering, and QA disagree about what a feature should do in edge cases.
- A team practicing BDD needs feature files drafted for review.
- A bug fix needs a regression scenario that captures the intended behavior.

Not for: unit-level technical tests, performance or load criteria (state those as non-functional requirements with numbers), or exploratory test charters.

## Inputs

- The user story or requirement, with any business rules. Required.
- Domain vocabulary: the terms users and the business use. Recommended.
- Known edge cases, limits, and error conditions. Optional.

## Procedure

1. **Extract the rules.** List each business rule the story implies (for example "orders over 50.00 ship free", "a user can have at most 5 active API tokens"). Each rule will get at least one scenario. Group scenarios under a `Rule:` keyword if the team's tooling supports Gherkin 6 or later.
2. **Write the happy path first.** One scenario for the main success case. Given sets up the relevant state, When is the single triggering action or event, Then states the observable outcome.
3. **Keep steps declarative.** Describe intent and outcome in domain language: "When the customer checks out" rather than "When I click the blue Checkout button". UI detail belongs in step definitions, not scenarios, so redesigns do not break the specification.
4. **Cover boundaries with Scenario Outlines.** For rules with thresholds, use a Scenario Outline with an Examples table covering just below, at, and just above the boundary, plus any special values (zero, empty, maximum).
5. **Add negative and error scenarios.** What happens when input is invalid, permissions are missing, a dependency fails, or a limit is reached? Then steps describe the user-visible result, including the message intent and that no unintended state change occurred.
6. **Factor common setup into Background** only when every scenario in the feature shares it, and keep Background short.
7. **Review quality.** Check each scenario: one behavior per scenario; exactly one When (avoid chains of When/And When); Then steps are observable outcomes, not internal implementation details; no conjunction-laden steps that hide two assertions; concrete example values rather than vague ones ("a cart total of 49.99" not "a small amount"); names that describe the behavior. Aim for roughly three to eight steps per scenario.
8. **Trace coverage.** Map scenarios back to the rules from step 1 and list any rule without a scenario.

## Expected output

```gherkin
Feature: Free shipping threshold
  Customers get free standard shipping on orders over a threshold
  so that larger baskets are rewarded.

  Rule: Orders over 50.00 qualify for free standard shipping

    Scenario Outline: Shipping cost depends on order subtotal
      Given a customer in the domestic shipping zone
      And their cart subtotal is <subtotal>
      When they choose standard shipping at checkout
      Then the shipping cost shown is <shipping>

      Examples:
        | subtotal | shipping |
        | 49.99    | 4.95     |
        | 50.00    | 4.95     |
        | 50.01    | 0.00     |

    Scenario: Free shipping is removed when the cart drops below the threshold
      Given a customer whose cart subtotal is 55.00 with free shipping applied
      When they remove an item worth 10.00
      Then the shipping cost shown is 4.95
      And they see that free shipping applies to orders over 50.00
```

Follow the feature file with a short coverage table: rule, scenarios, gaps.

## Constraints and limitations

- Do not invent business rules; when a rule is unclear (is the threshold inclusive?), write the scenario with the question marked and list it for the product owner.
- Scenarios describe behavior, not test data management or environment setup.
- Too many scenarios on one feature signal the story should be split.
- Gherkin keywords are localized in some tools; keep English keywords unless the team specifies otherwise.

## Examples

Weak (imperative, multiple behaviors):
"Given I am on the login page When I type my email And I type my password And I click Login Then I see the dashboard And I see my name"

Improved (declarative, one behavior):
"Given a registered user with a verified account When they sign in with valid credentials Then they reach their dashboard"

Separate scenario for the rule about lockout:
"Given a registered user who has entered a wrong password 4 times in 15 minutes When they enter a wrong password again Then their account is temporarily locked And they are told how to unlock it"
