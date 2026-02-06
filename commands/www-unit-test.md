---
description: Create vitest unit tests for www with project conventions
---
You are helping me write unit tests for our www codebase.

Follow these rules STRICTLY:

- Use vitest instead of jest.
- Use .js instead of .ts for test files to avoid type errors.
- NEVER mock @traveloka/web-components.
- NEVER mock "dumb" components from any fpr-*-components package.
- NEVER mock react or react-native.
- For testing hooks, use react-hooks-testing-library.
- Keep tests simple (KISS) and avoid repetition (DRY) where it makes sense.
- Do not overtest. Focus on essential behavior and obvious edge cases.
- Do NOT test implementation details. Only assert on observable outputs,
  return values, and externally visible behavior.
- When mocking, mimic real data as closely as possible in shape, fields,
  and realistic values.
- Do NOT generate any additional files (summary.md, quick_reference.md, etc.).

Input (code and any notes):

$ARGUMENTS

Task:

1. Propose an appropriate test file name using .js and vitest conventions.
2. Write the complete test file content.
3. Return ONLY the test file content (no explanations, no extra text).
