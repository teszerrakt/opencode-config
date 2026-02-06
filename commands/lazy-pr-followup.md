---
description: Follow up on PR review - check if comments are addressed and approve
---

You are helping me follow up on Pull Request #$ARGUMENTS that I previously reviewed.

## Step 1: Gather Current PR State

Fetch the following using gh CLI:

1. **Get current GitHub username:**
   !`gh api user --jq '.login'`

2. **PR basic info:**
   !`gh pr view $ARGUMENTS --json title,headRefName,state,headRefOid,author`

3. **All review comments (to find my comments and replies):**
   !`gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/comments --jq '.[] | {id, path, line, original_line, body, user: .user.login, created_at, updated_at, in_reply_to_id}'`

4. **Review threads with resolved status (GraphQL):**
   !`gh api graphql -f query='query($owner: String!, $repo: String!, $pr: Int!) { repository(owner: $owner, name: $repo) { pullRequest(number: $pr) { reviewThreads(first: 100) { nodes { isResolved, comments(first: 10) { nodes { id, databaseId, body, author { login } } } } } } } }' -f owner='{owner}' -f repo='{repo}' -F pr=$ARGUMENTS`

5. **My previous reviews:**
   !`gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/reviews --jq '.[] | {id, user: .user.login, state, body, submitted_at}'`

6. **All commits on the PR:**
   !`gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/commits --jq '.[] | {sha: .sha[0:7], message: .commit.message, date: .commit.committer.date, author: .commit.author.name}'`

7. **Files changed (summary):**
   !`gh pr diff $ARGUMENTS --name-only`

8. **Full diff (for verifying changes):**
   !`gh pr diff $ARGUMENTS`

## Step 2: Identify My Previous Comments

From the review comments gathered in Step 1:

1. Filter comments where `user` matches my GitHub username (from Step 1.1)
2. Exclude replies (comments with `in_reply_to_id` set) - we want top-level comments only
3. Create a list of my review comments with: `id`, `path`, `line`, `body`, `created_at`

## Step 3: Analyze Each Comment's Resolution Status

For each of my comments, determine its status using these criteria (in priority order):

### Status Definitions

| Status           | Emoji | Criteria                                                                                                                                                                                                                                                                              |
| ---------------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Resolved**     | ✅    | Comment thread is marked as "resolved" in GitHub (from GraphQL reviewThreads.isResolved)                                                                                                                                                                                              |
| **Replied**      | 💬    | PR author replied with acknowledgment. Look for replies (comments with `in_reply_to_id` matching my comment's `id`) from the PR author containing words like: "fixed", "done", "updated", "addressed", "good point", "will do", "thanks", "changed", "removed", "added", "refactored" |
| **Code Changed** | 🔄    | The file containing my comment was modified in commits AFTER my comment's `created_at` timestamp. Show a brief diff summary of what changed in that file.                                                                                                                             |
| **Unaddressed**  | ⏳    | None of the above criteria are met - comment is still pending                                                                                                                                                                                                                         |

A comment can have multiple statuses (e.g., both Replied AND Code Changed). Prioritize showing the most "resolved" status.

## Step 4: Present Status Summary

Display a clear summary table:

```
## 📋 Comment Follow-up Status for PR #$ARGUMENTS

| # | Status | File | Line | My Comment (truncated) | Details |
|---|--------|------|------|------------------------|---------|
| 1 | ✅ | src/foo.ts | 42 | 🐛 props in useEffect... | Marked resolved |
| 2 | 💬 | src/bar.ts | 15 | 🧹 Consider extracting... | Author replied: "Fixed!" |
| 3 | 🔄 | src/baz.ts | 99 | 🎨 as any cast... | File modified in abc123 |
| 4 | ⏳ | src/qux.ts | 50 | ❓ What happens when... | No reply or changes |

### Summary
- ✅ Resolved: X
- 💬 Replied: X
- 🔄 Code Changed: X
- ⏳ Unaddressed: X
```

### For "🔄 Code Changed" Comments

Show a brief, relevant diff excerpt for each comment where the code changed:

```
### Changes in `src/baz.ts` (related to comment #3)

My comment was about: "🎨 as any cast bypasses type safety..."

Relevant changes:
\`\`\`diff
- const newAddonData = newAddonMap[addOnId] as any;
+ const newAddonData = newAddonMap[addOnId];
+ const freshAddonProductInfo = newAddonData?.addOnData?.addOnProductInfo;
\`\`\`
```

This helps verify if the change actually addresses the comment.

## Step 5: Decision Point

Based on the analysis, present one of these scenarios:

### Scenario A: All Comments Addressed (no ⏳ Unaddressed)

```
🎉 All X comments appear to be addressed!

- ✅ Resolved: X
- 💬 Replied: X
- 🔄 Code Changed: X

Ready to approve?
```

Use question tool with options:

- "Approve PR"
- "Verify changes first" (then show relevant diffs for 🔄 items)
- "Still have concerns" (let user explain)

### Scenario B: Some Comments Unaddressed (has ⏳)

```
⚠️ X of Y comments still unaddressed:

1. `src/qux.ts:50` - "❓ What happens when..."
2. `src/foo.ts:100` - "🐛 Potential null pointer..."

The other Y comments are addressed (✅/💬/🔄).
```

Use question tool with options:

- "Approve anyway - minor issues"
- "Request changes again"
- "Post a follow-up nudge" (prompts for message)
- "Wait - do nothing for now"

## Step 6: Take Action

Based on user's choice:

### Approve PR

```bash
gh pr review $ARGUMENTS --approve -b "LGTM - thanks for addressing the review comments! 🚀"
```

### Request Changes Again

```bash
gh pr review $ARGUMENTS --request-changes -b "Please address the remaining review comments:
- [ ] File:Line - Comment summary
- [ ] File:Line - Comment summary
"
```

### Post Follow-up Nudge

Ask user what message to post, then:

```bash
gh pr comment $ARGUMENTS -b "<user's message>"
```

### Verify Changes First

Show the full diff for files with 🔄 status, then return to decision point.

## Important Notes

- This command is for FOLLOW-UP only - it checks status of existing comments
- If you spot NEW issues during follow-up, run `/lazy-pr-review` again instead
- Always show the diff context for "Code Changed" items so we can verify the fix
- Be generous in detecting "acknowledgment" replies - authors may say "thanks, fixed" or just "done"
- Consider a comment addressed if ANY of the criteria (Resolved/Replied/Changed) are met
