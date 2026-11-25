---
name: spec-plan
description: Plans a feature or fix in a fresh Opus (medium effort) session against origin/development. The plan must pass every readiness gate and an independent review, reaching at least 80% confidence against CLAUDE.md, before it is saved to tasks/. Invoke via "/spec-plan <problem or feature>".
argument-hint: <problem or feature to plan>
disable-model-invocation: true
---

# /spec-plan

Problem to plan: **$ARGUMENTS**

If no problem was given, ask the user for one and stop.

Section 1 runs in the session where the user typed the command. Section 2 runs in the Opus
session that section 1 starts. Never plan in the invoking session.

## 1. Start a fresh Opus medium session

1. `mcp__ccd_session__start_session` exists only in the Claude desktop app. If it isn't available,
   tell the user this skill needs the desktop app and stop.
2. Call `get_session("self")`. The app only starts sessions on the same model family or a cheaper
   one, at the same effort or lower. If this session isn't on Opus, or its effort is below medium,
   tell the user to switch this session first and stop.
3. Call `start_session` with:
   - `initiation: "user_asked"`, `context: "fresh"`;
   - `model: "claude-opus-5-5"` (or the current Opus id), `effort: "medium"`;
   - `use_worktree: true`, `source_branch: "development"`;
   - `title: "Spec plan: <short problem>"`;
   - the brief below as `prompt`;
   - a `background` that says the repository uses the `/spec-plan` → `/spec-execute` →
     `/spec-review` workflow.
4. Link the session for the user and end your turn.

Brief, with absolute paths filled in:

> Follow section 2 of `<repo>/.claude/skills/spec-plan/SKILL.md` to plan: <problem>.
> Save the plan in `<repo>/tasks/`.

## 2. Plan (in the Opus session)

Change no source code here.

1. **Baseline.** Run `git fetch origin && git switch --detach origin/development`. Note the short
   commit id for the plan's **Based on** line. Read `CLAUDE.md`; its rules are the bar the plan has
   to clear.
2. **Understand.** Restate the problem in one or two sentences. Read the code it touches. For a bug,
   find the root cause; for a feature, find where it fits the existing architecture.
3. **Draft** the plan with the template below.
4. **Check the readiness gates.** Fix the plan until every gate passes:
   - The root cause, or where the feature fits, is confirmed in the code with `file:line`
     references, not assumed.
   - Every step names the files it changes and can be explained in one or two sentences.
   - No step needs a hack, a workaround, a magic number, a new layer, or a wider public API than
     the problem requires.
   - Every new rule in `Layout/` or `Interaction/` has a named test.
   - Every CLAUDE.md rule the plan touches appears in **Rules check** with how it complies.
   - Every open question is either answered (by the code, or by the user through
     `AskUserQuestion`) or accepted in **Risks** with a reason.
5. **Get an independent review.** Start a `general-purpose` subagent with the `Agent` tool. Give it
   only the plan text and the path to `CLAUDE.md`, never your reasoning, and ask it to:
   - find a wrong root cause, missing steps, hacks, untested rules, or a simpler correct approach;
   - mark each finding **blocking** or **non-blocking**.

   Fix blocking findings, then return to step 4. After three review rounds that still end with
   blocking findings, show the user the remaining findings and ask how to proceed.
6. **Score.** Confidence is your estimate that executing the plan as written solves the problem
   within CLAUDE.md. Score it only after every gate passes and the review has no blocking findings;
   the gates and the review decide readiness, and the number summarizes them. Below 80%, find what
   is missing, then go back to step 2.
7. **Save** the plan as `tasks/<YYYY-MM-DD>-<short-slug>.md` (in the folder from the brief). Tell
   the user the path, the confidence, the accepted risks, and that `/spec-execute` runs it.

### Plan template

```markdown
# <Title>

- **Status:** ready
- **Confidence:** <N>%
- **Based on:** `origin/development` @ `<short commit id>`
- **Branch:** new branch off `development`
- **Planned in session:** `<this session's id, from get_session("self")>`
- **Created:** <YYYY-MM-DD> by /spec-plan

## Problem
<One or two sentences.>

## Root cause / where it fits
<What the code does today and why, with `file:line` references.>

## Approach
<The chosen solution and why it is the simplest correct one. Rejected alternatives, one line each.>

## Steps
1. <One change> — `path/to/File.swift`

## Tests
<Tests to add or update, and how to run them.>

## Rules check
<One line per CLAUDE.md rule this plan touches, and how it complies.>

## Review
<Non-blocking findings from the independent review, and what you did with each.>

## Risks
<Accepted open questions and why each is acceptable.>

## Out of scope
<What this plan deliberately doesn't do.>
```
