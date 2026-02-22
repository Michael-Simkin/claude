# Code generation patterns

## React components

- Never define components inside other components. Inline the logic or extract to a separate file.
- Prefer component library props (size, gap, direction, variant) over custom CSS. Only write CSS when no prop exists.
- Consolidate related props: don't use multiple props for the same concept (e.g., use `provider: Provider` instead of separate `providerId` and `providerName`).

## Test data

- Use faker-based generator functions for mock/test data instead of hardcoded values.
- Mock data must match real API shapes and realistic values (e.g., emails for email fields, not random strings).

## Test structure

- Follow AAA (Arrange/Act/Assert) comment convention when the surrounding test file uses it. Check adjacent tests in the same file for this pattern before writing new tests.
- When multiple test cases share the same shape (same inputs/outputs structure, same assertion logic), consolidate them into a single `it.each` table-driven test rather than separate `it` blocks or multiple `it.each` groups.
- Extract repeated test setup and assertions into test driver helper methods with descriptive names. Consolidate related assertions into a single driver method (e.g., `driver.assertSettings(response, expectedSettings)`) rather than splitting into per-concept methods (e.g., separate `assertAutoJoin` and `assertLockedFields`).

## Type organization

- Export shared types from API/service files, not from hooks or query files.
- Prefer schema types from external libraries over redefining them locally.

## Cross-repo consistency

- Before implementing a pattern, check sibling repos in the same workspace for established conventions.
- When a reference implementation exists in a related repo, copy and adapt rather than reinvent.
