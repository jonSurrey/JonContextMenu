---
name: spec-execute
description: Executes a ready plan written by /spec-plan or /spec-review in a fresh Sonnet (medium effort) session, checks the result against the plan, opens a PR into development, then deletes the plan. Stops and marks the plan blocked instead of improvising. Invoke via "/spec-execute [plan]"; without an argument it lists the ready plans in tasks/.
argument-hint: "[plan file or name in tasks/]"
disable-model-invocation: true
---

# /spec-execute

Plan to execute: **$ARGUMENTS**

Section 1 runs in the session where the user typed the command. Section 2 runs in the Sonnet
session that section 1 starts. Never execute in the invoking session.

## 1. Start a fresh Sonnet medium session

1. `mcp__ccd_session__start_session` exists only in the Claude desktop app. If it isn't available,
   tell the user this skill needs the desktop app and stop.
2. Call `get_session("self")`. New sessions can't run at a higher effort than this one, so if its
   effort is below medium, tell the user to raise it first and stop.
3. **Pick the plan.** Read the **Status** line of each plan in `tasks/`.
   - An argument was given: match it to a file in `tasks/` (a path or part of a file name). If that
     plan is blocked, show its reason, suggest `/spec-review`, and stop.
   - No argument: consider only plans with `Status: ready`, and mention any blocked ones by name.
     None ready → tell the user there's nothing to execute and stop. One → use it. Several → ask
     which with `AskUserQuestion`, showing each plan's title and confidence.
4. Call `start_session` with:
   - `initiation: "user_asked"`, `context: "fresh"`;
   - `model: "claude-sonnet-5-5"` (or the current Sonnet id), `effort: "medium"`;
   - `use_worktree: true`, `source_branch: "development"`;
   - `title: "Spec execute: <plan title>"`;
   - the brief below as `prompt`;
   - a `background` that says the repository uses the `/spec-plan` → `/spec-execute` →
     `/spec-review` workflow.
5. Link the session for the user and end your turn.

Brief, with absolute paths filled in:

> Follow section 2 of `<repo>/.claude/skills/spec-execute/SKILL.md` to execute the plan at
> `<repo>/tasks/<plan>.md`.

## 2. Execute (in the Sonnet session)

**Stopping.** At any step below that says *stop*, don't improvise:
- set the plan's **Status** to `blocked — <one-line reason>`;
- add a `## Blocked` section at the end of the plan with what you tried and what's needed;
- leave the plan file in place, and report the reason to the user.

That plan is then the input for `/spec-review`.

1. Read `CLAUDE.md`, then the plan at the absolute path in the brief.
2. **Branch.** If `git status` shows uncommitted changes, stop. Run `git fetch origin`. If the
   plan's **Branch** names an existing branch, switch to it. Otherwise run
   `git switch -c spec/<plan-slug> origin/development`.
3. **Check the plan isn't stale.** List the files the plan's steps touch. If any of them changed
   between the **Based on** commit and your branch's starting point
   (`git diff --stat <based-on> HEAD -- <files>`), stop: the plan was written against different
   code.
4. **Implement the steps in order, exactly as planned.** Small mechanical deviations, like a
   renamed symbol, are fine; note each one for the PR. Stop if any of these happen:
   - a step turns out to be wrong;
   - a step would need a hack or a workaround;
   - the plan misses something that changes the approach.
5. **Verify.** Run the tests the way CLAUDE.md says, and build the example app if the change
   touches it. Fix failures that the plan covers; any other failure is a stop.
6. **Check the result against the plan.** Read the full diff of your branch against its starting
   point and confirm:
   - every step is done;
   - nothing changed outside the plan's steps;
   - the CLAUDE.md rules in **Rules check** still hold.

   Fix gaps that the plan covers; anything else is a stop.
7. **Commit** following CLAUDE.md: conventional commits, one logical change per commit.
8. **Open the PR.** Push and open a PR into `development`, or push to the existing PR if the plan's
   **Branch** named one. Never merge. The PR body has:
   - a summary of the change;
   - **Plan check:** the result of step 6, step by step;
   - deviations from the plan;
   - test results;
   - a final section that starts with the line `Executed from a /spec-plan plan`, followed by the
     full plan text. `/spec-review` uses that line to find this work.
9. **Delete the plan file** (absolute path from the brief), only after the PR is open.
   Report the PR link to the user.
