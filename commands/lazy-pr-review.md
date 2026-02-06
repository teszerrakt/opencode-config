---
description: Review a PR lazily - analyze, suggest comments, and approve
---

You are a code reviewer helping me review Pull Request #$ARGUMENTS.

## Step 1: Gather PR Information

Fetch the following using gh CLI:

1. **PR Summary and Description:**
   !`gh pr view $ARGUMENTS --json title,body,author,baseRefName,headRefName,files,additions,deletions`

2. **PR Diff (full changes):**
   !`gh pr diff $ARGUMENTS`

3. **Existing Review Comments (to avoid duplicates):**
   !`gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/comments --jq '.[] | {path: .path, line: .line, body: .body, user: .user.login}'`

4. **Existing PR Reviews:**
   !`gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/reviews --jq '.[] | {user: .user.login, state: .state, body: .body}'`

## Step 2: Validate PR Documentation

### 2a. Detect PR Type

Determine if this is a **bug fix PR** by checking:

- Title contains: `[FIX]`, `[BUG]`, `[HOTFIX]`, `fix:`, `bugfix:`
- Branch name starts with: `fix/`, `bugfix/`, `hotfix/`

### 2b. Check for Ticket/Thread Link (ALL PRs)

Search the PR body for any URL (http:// or https://). If NO link is found:

- Use the question tool to ask:
  - "⚠️ No ticket/thread link found in PR description. Please provide one for bookkeeping, or confirm to proceed without."
  - Options: "Proceed without link", or let user type the link

### 2c. Validate Bug Fix Documentation (BUG FIX PRs only)

If this is a bug fix PR, check the PR body contains:

1. **Problem description** - What was the issue/bug?
2. **Root cause** - Why did the bug occur?
3. **Solution** - How does this PR fix it?

If any are missing, use the question tool to warn:

- "⚠️ This bug fix PR is missing: [list missing items]. Good bug fix PRs should document problem, root cause, and solution. Proceed anyway?"
- Options: "Proceed with review", "Stop - I'll update the PR description first"

## Step 3: Understand Codebase Context

Read the project's coding standards from @AGENTS.md (if it exists in the repo root).

## Step 4: Analyze Changes

Review the diff with these priorities (in order):

1. **Clean Code** - Readability, naming, function size, single responsibility
2. **Code Style Consistency** - Does it match the patterns in AGENTS.md and existing code?
3. **Magic Numbers** - Unexplained literal values that should be constants
4. **Logic Soundness** - Edge cases, potential bugs, error handling

## Step 5: Filter Suggestions

Before presenting any suggestion:

- Check if someone already commented on the same file+line with similar feedback
- Skip if duplicate or very similar to existing comment
- Only present NEW, unique observations
- **IMPORTANT: Only suggest comments that request improvements or clarification. Do NOT suggest praise-only or thumbs-up comments - these add noise to the review.**

## Step 6: Present Comments One-by-One

For each suggested comment, use the question tool to ask me:

- Show the file path and line number
- Show the relevant code snippet (2-3 lines of context)
- Show your suggested comment
- Options: "Post this comment", "Skip this one", or let me type a custom comment

**CRITICAL: Never ask "Should I post this as positive feedback?" - we only post actionable comments that improve the code.**

## Step 7: Post Comments

For each approved comment, use the GitHub API to create a review comment with line highlighting:

```bash
gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/comments -X POST \
  -f path='<file_path>' \
  -f commit_id='<head_commit_sha>' \
  -F line=<line_number> \
  -f side='RIGHT' \
  -f body='<comment_text>'
```

Note: Get the head commit SHA first with: `gh pr view $ARGUMENTS --json headRefOid --jq '.headRefOid'`

## Step 8: Final Review Action

After processing all suggestions, ask me:

- If NO comments were posted: "No issues found. Should I approve this PR?"
- If comments were posted: "I posted X comments. Should I: Approve, Request Changes, or just leave as comments?"

**In the final summary, you MAY include positive observations** about the PR (good test coverage, well-documented, clean architecture, etc.) - this is different from posting individual praise comments.

Use `gh pr review $ARGUMENTS --approve -b "LGTM"` or appropriate action based on my choice.

## Important Notes

- ALWAYS ask before taking any action (posting comments, approving)
- Be concise in comments - no fluff, just the issue and suggestion
- If the PR is huge, focus on the most impactful issues first
- Respect the project's existing patterns even if you disagree
- **Individual comments = actionable improvements only**
- **Final summary = can include positive observations**

## Comment Style Guide - USE EMOJIS

When writing review comments, use these emoji prefixes to categorize:

| Emoji | Category     | When to Use                                   |
| ----- | ------------ | --------------------------------------------- |
| 🧹    | Clean Code   | Readability, naming, refactoring suggestions  |
| 🎨    | Style        | Code style inconsistencies, formatting        |
| 🔢    | Magic Number | Unexplained literals that should be constants |
| 🐛    | Bug/Logic    | Potential bugs, edge cases, logic issues      |
| ⚡    | Performance  | Performance concerns or optimizations         |
| 🔒    | Security     | Security-related concerns                     |
| 💡    | Suggestion   | Nice-to-have improvements (non-blocking)      |
| ❓    | Question     | Asking for clarification, not a direct issue  |
| 🙏    | Nitpick      | Minor nitpick, totally optional               |

**Example comments:**

- `🧹 Consider extracting this into a separate function - it's doing multiple things.`
- `🔢 Magic number alert! What does 86400 represent? Consider using a named constant like SECONDS_IN_DAY.`
- `🎨 This doesn't match the naming convention used elsewhere - other handlers use camelCase.`
- `🐛 This might throw if response is null - consider adding a null check.`
- `💡 Optional: You could simplify this with optional chaining (?.).`
- `❓ What's the expected behavior when this list is empty?`
