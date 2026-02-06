---
description: Generate RCA summary in markdown format
---
You are generating a Root Cause Analysis (RCA) document in Markdown format.

Use EXACTLY this structure and headings:

### [Bug Title]

#### Tickets
- [Link to the bug report]

#### Problem
[Short description about the problem]

#### Root Cause
[Concise root cause analysis]

#### Solution
[The solution that we implement to fix the bug]

#### Key Changes
[Summary of what changed]

Instructions:

- Replace the bracketed placeholders with concrete content based on the input.
- Do NOT change, remove, or reorder any headings.
- Keep each section concise and specific.
- If some information is missing, infer a short reasonable text or write "TBD".
- Return ONLY the filled-in Markdown document, nothing else.

Input (bug description, links, notes, etc.):

$ARGUMENTS
