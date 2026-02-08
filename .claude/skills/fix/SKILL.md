---
name: fix
description: Fix a GitHub issue end-to-end — fetches issue, creates branch, plans and implements fix, runs validation, opens PR, returns to main.
argument-hint: [issue-number-or-url]
disable-model-invocation: true
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, WebFetch, WebSearch
---

# Fix GitHub Issue

You are fixing a GitHub issue for the exercism/website repository.

## Issue details

```json
!`gh issue view $ARGUMENTS --json number,title,body,labels,comments`
```

Issue number: !`echo "$ARGUMENTS" | grep -oE '[0-9]+$'`

## Critical: Protect existing work

**Before doing anything else**, check the current git state:

- Run `git status` to check for uncommitted changes and the current branch.
- If there are **uncommitted or staged changes**, STOP and ask the user how to proceed. Do NOT checkout another branch, stash, or discard anything.
- If you are **not on main**, STOP and ask the user how to proceed. Do NOT switch branches or reset.

Never destroy or discard existing work.

## Workflow

Follow these steps in order. Do not skip any step.

### Step 1: Understand the issue

Read the issue details above carefully. Identify:

- What is broken or needs to change
- Which parts of the codebase are likely affected
- Any reproduction steps or error messages mentioned

Read the relevant `docs/context/` files for the area of the codebase involved.

### Step 2: Plan the fix

**Do NOT create a branch yet.** Stay on the current branch while planning.

Use /plan to enter plan mode. Explore the codebase thoroughly:

- Find the relevant files using Glob and Grep
- Read the code to understand current behavior
- Identify what needs to change and why
- Check for existing test coverage
- Look at similar patterns in the codebase for reference

Design a complete fix before writing any code.

### Step 3: Create a feature branch

Only create the branch **after the plan is approved**. The issue number has been extracted above (works whether the argument was a full URL like `https://github.com/exercism/website/issues/8370` or just `8370`).

```bash
git checkout main
git pull --ff-only origin main
git checkout -b fix/<issue-number>
```

### Step 4: Implement the fix

After the plan is approved and the branch is created, implement the changes:

- Follow existing patterns and conventions in the codebase
- Business logic belongs in `/app/commands/` using the Mandate pattern
- Keep controllers thin — delegate to commands
- Add or update tests as appropriate (Minitest, FactoryBot)
- Keep changes minimal and focused on the issue

### Step 5: Run pre-commit validation

Run all three checks. All must pass before committing:

```bash
bundle exec rubocop --except Metrics
yarn test
bundle exec rails test:zeitwerk
```

If any check fails, fix the issues and re-run until all pass.

### Step 6: Commit the changes

Stage only the files you changed (do not use `git add -A` or `git add .`). Write a clear commit message that describes the fix.

### Step 7: Push and create a PR

Push the branch and create a pull request:

```bash
git push -u origin fix/<issue-number>
```

Create the PR using `gh pr create`. The PR body must include `Closes #<issue-number>` to auto-close the issue on merge:

```bash
gh pr create --title "<concise title>" --body "$(cat <<'EOF'
Closes #<issue-number>

## Summary
<bullet points describing what changed and why>

## Test plan
<checklist of how the fix was validated>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Step 8: Return to main

```bash
git checkout main
```

Report the PR URL to the user.
