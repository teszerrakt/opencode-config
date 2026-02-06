# OpenCode Configuration

Personal OpenCode configuration files and custom commands.

## Setup

1. Clone this repo to your preferred location
2. Copy `opencode.json` to `~/.config/opencode/opencode.json`
3. Copy the `commands/` folder to `~/.config/opencode/commands/`
4. Set the `CONTEXT7_API_KEY` environment variable with your Context7 API key

## Commands

| Command | Description |
|---------|-------------|
| `/generate-commit-message` | Generate a high-quality git commit message |
| `/lazy-pr-review` | Review a PR - analyze, suggest comments, and approve |
| `/lazy-pr-followup` | Follow up on PR review - check if comments are addressed |
| `/rca` | Generate RCA summary in markdown format |
| `/www-unit-test` | Create vitest unit tests for www with project conventions |

## Configuration

The `opencode.json` includes:
- **Context7** - MCP server for documentation lookup
- **shadcn** - MCP server for shadcn/ui components

Make sure to set your `CONTEXT7_API_KEY` environment variable before using.
