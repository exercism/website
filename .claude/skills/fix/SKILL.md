---
name: fix
description: Fix a GitHub issue end-to-end — fetches issue, creates worktree, plans and implements fix, runs validation, opens PR, cleans up.
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

## Critical: Two phase.

Your work is split into two phases.

The first phase is purely planning. You must **NOT** make any changes to git state (switching branches, creating branches, creating worktrees, etc). You should presume that other work is SIMULTANEOUSLY happening WHILE you are planning.

Once the plan has been **APPROVED** by the user you should check the current git state:

- Run `git status` to check for uncommitted changes.
- If there are **uncommitted or staged changes**, STOP and ask the user how to proceed. Do NOT stash or discard anything.

Never destroy or discard existing work.

If the plan has been approved and the working tree is clean, continue with your work.

## Workflow

Follow these steps in order. Do not skip any step.

### Step 1: Understand the issue

Read the issue details above carefully. Identify:

- What is broken or needs to change
- Which parts of the codebase are likely affected
- Any reproduction steps or error messages mentioned

Read the relevant `docs/context/` files for the area of the codebase involved.

### Step 2: Plan the fix

**Do NOT create a branch or worktree yet.** Stay on the current branch while planning.

Use /plan to enter plan mode. Explore the codebase thoroughly:

- Find the relevant files using Glob and Grep
- Read the code to understand current behavior
- Identify what needs to change and why
- Check for existing test coverage
- Look at similar patterns in the codebase for reference

Design a complete fix before writing any code.

### Step 3: Create a worktree

Only create the worktree **after the plan is approved**. The issue number has been extracted above (works whether the argument was a full URL like `https://github.com/exercism/website/issues/8370` or just `8370`).

```bash
git pull --ff-only origin main
mkdir -p worktrees
git worktree add worktrees/fix-<issue-number> -b fix/<issue-number>
cd worktrees/fix-<issue-number>
```

After creating the worktree, symlink `node_modules` and husky from the main repo so that JS tooling (prettier, eslint, jest) and pre-commit hooks work without a full `yarn install`:

```bash
ln -s /Users/iHiD/Code/exercism/website/node_modules node_modules
ln -s /Users/iHiD/Code/exercism/website/.husky/_ .husky/_
```

**CRITICAL:** You MUST `cd` into the worktree immediately after creating it. All subsequent work — file reads, edits, bash commands, tests — MUST happen from inside the worktree directory using `cd worktrees/fix-<issue-number> && <command>` on every Bash call. Do NOT use absolute paths to the worktree from the main repo. The main repo stays untouched on its current branch.

### Step 4: Implement the fix

After the plan is approved and the worktree is created, implement the changes:

- Follow existing patterns and conventions in the codebase
- Business logic belongs in `/app/commands/` using the Mandate pattern
- Keep controllers thin — delegate to commands
- Add or update tests as appropriate (Minitest, FactoryBot)
- Keep changes minimal and focused on the issue

### Step 5: Run tests

Run the relevant tests for the changes you made:

```bash
bundle exec rails test <test-file-or-directory>
```

If you made front-end changes, also run `yarn test` before committing.

Rubocop and brakeman will be checked automatically by the pre-commit hook when you commit — you do not need to run them manually.

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

### Step 8: Clean up worktree

```bash
cd /Users/iHiD/Code/exercism/website
git worktree remove worktrees/fix-<issue-number>
```

This removes the worktree directory. The branch remains on the remote for the PR.

Report the PR URL to the user.
