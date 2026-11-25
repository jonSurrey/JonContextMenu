---
name: spec-execute
description: Executes a plan written by /spec-plan or /spec-review in a dedicated Sonnet (medium effort) session, opens a PR into development, then deletes the plan. Invoke via "/spec-execute [plan]"; without an argument it lists the plans in tasks/.
argument-hint: "[plan file or name in tasks/]"
disable-model-invocation: true
---

# /spec-execute

Plan to execute: **$ARGUMENTS**

Section 1 runs in the session where the user typed the command. Section 2 runs in the Sonnet
session that section 1 hands the work to. Never execute in the invoking session.

## 1. Hand off to a Sonnet medium session

1. `mcp__ccd_session__start_session` exists only in the Claude desktop app. If it isn't available,
   tell the user this skill needs the desktop app and stop.
2. Call `get_session("self")`. New sessions can't run at a higher effort than this one, so if its
   effort is below medium, tell the user to raise it first and stop.
3. **Pick the plan.**
   - An argument was given: match it to a file in `tasks/` (a path or part of a file name).
   - No argument: list `tasks/*.md`. None → tell the user there's nothing to execute and stop.
     One → use it. Several → ask which with `AskUserQuestion`, showing each plan's title and
     confidence.
4. Look for a session to reuse. From `list_sessions`, take non-archived sessions whose title starts
   with `Spec execute:`. Keep one only if all of these hold:
   - `get_session` reports a Sonnet model and `medium` effort;
   - it is not in the middle of a turn;
   - `get_usage(session_id)` reports its context window and it is **under 50% full**. If usage is
     unavailable, don't reuse it.
5. Send the brief below:
   - **Reusable session found** (most recent one): `send_message` to it.
   - **None:** `start_session` with `initiation: "user_asked"`, `context: "fresh"`,
     `model: "claude-sonnet-5-5"` (or the current Sonnet id), `effort: "medium"`,
     `use_worktree: true`, `source_branch: "development"`, `title: "Spec execute: <plan title>"`,
     the brief as `prompt`, and a `background` that says the repository uses the
     `/spec-plan` → `/spec-execute` → `/spec-review` workflow.
6. Link the session for the user and end your turn.

Brief, with absolute paths filled in:

> Follow section 2 of `<repo>/.claude/skills/spec-execute/SKILL.md` to execute the plan at
> `<repo>/tasks/<plan>.md`.

## 2. Execute (in the Sonnet session)

1. Read `CLAUDE.md`, then the plan at the absolute path in the brief.
2. **Branch.** If `git status` shows uncommitted changes, stop and report. If the plan's
   **Branch** names an existing branch, fetch and switch to it. Otherwise run
   `git fetch origin && git switch -c spec/<plan-slug> origin/development`.
3. **Implement the steps in order, exactly as planned.** Small mechanical deviations, like a
   renamed symbol, are fine; list them for the PR. Stop instead of improvising if any of these
   happen:
   - a step turns out to be wrong;
   - a step would need a hack or a workaround;
   - the plan misses something that changes the approach.

   When you stop, leave the plan file in place and report exactly what blocked you. That report is
   the input for `/spec-review`.
4. **Verify.** Run the tests the way CLAUDE.md says, and build the example app if the change
   touches it. Fix failures that the plan covers; anything else is a stop, as in step 3.
5. **Commit** following CLAUDE.md: conventional commits, one logical change per commit.
6. **Open the PR.** Push and open a PR into `development`, or push to the existing PR if the plan's
   **Branch** named one. Never merge. The PR body has:
   - a summary of the change;
   - deviations from the plan;
   - test results;
   - a final section that starts with the line `Executed from a /spec-plan plan`, followed by the
     full plan text. `/spec-review` uses that line to find this work.
7. **Delete the plan file** (absolute path from the brief), only after the PR is open.
   Report the PR link to the user.
