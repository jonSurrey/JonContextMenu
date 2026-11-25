---
name: spec-plan
description: Plans a feature or fix in a dedicated Opus (medium effort) session, iterating until the plan reaches at least 80% confidence against CLAUDE.md, then saves it to tasks/. Invoke via "/spec-plan <problem or feature>".
argument-hint: <problem or feature to plan>
disable-model-invocation: true
---

# /spec-plan

Problem to plan: **$ARGUMENTS**

If no problem was given, ask the user for one and stop.

Section 1 runs in the session where the user typed the command. Section 2 runs in the Opus
session that section 1 hands the work to. Never plan in the invoking session.

## 1. Hand off to an Opus medium session

1. `mcp__ccd_session__start_session` exists only in the Claude desktop app. If it isn't available,
   tell the user this skill needs the desktop app and stop.
2. Call `get_session("self")`. The app only starts sessions on the same model family or a cheaper
   one, at the same effort or lower. If this session isn't on Opus, or its effort is below medium,
   tell the user to switch this session first and stop.
3. Look for a session to reuse. From `list_sessions`, take non-archived sessions whose title starts
   with `Spec plan:` or `Spec review:`. Keep one only if all of these hold:
   - `get_session` reports an Opus model and `medium` effort;
   - it is not in the middle of a turn;
   - `get_usage(session_id)` reports its context window and it is **under 50% full**. If usage is
     unavailable, don't reuse it.
4. Send the brief below:
   - **Reusable session found** (most recent one): `send_message` to it.
   - **None:** `start_session` with `initiation: "user_asked"`, `context: "fresh"`,
     `model: "claude-opus-5-5"` (or the current Opus id), `effort: "medium"`, `use_worktree: false`,
     `title: "Spec plan: <short problem>"`, the brief as `prompt`, and a `background` that says the
     repository uses the `/spec-plan` → `/spec-execute` → `/spec-review` workflow.
5. Link the session for the user and end your turn.

Brief, with absolute paths filled in:

> Follow section 2 of `<repo>/.claude/skills/spec-plan/SKILL.md` to plan: <problem>.
> Save the plan in `<repo>/tasks/`.

## 2. Plan (in the Opus session)

Read `CLAUDE.md` first. Its rules are the bar the plan has to clear. Change no source code here.

1. **Understand.** Restate the problem in one or two sentences. Read the code it touches. For a bug,
   find the root cause; for a feature, find where it fits the existing architecture.
2. **Draft** the plan with the template below.
3. **Challenge the draft against CLAUDE.md.** Is it the simplest correct solution? Does any step
   lean on a hack, a workaround, a magic number, a new layer, or a wider public API? Can each step
   be explained in one or two sentences? Does every new rule in `Layout/` or `Interaction/` get a test?
   Fix what fails.
4. **Score your confidence** (0–100%) that executing the plan as written solves the problem and
   respects CLAUDE.md. Write down what keeps it below 100%.
5. **Below 80%:** resolve the biggest uncertainty first. Read more code, run a throwaway experiment
   (discard it afterward), or ask the user with `AskUserQuestion` when it's their decision. Then go
   back to step 2. Only raise the score when you have new evidence.
6. **At 80% or more:** save the plan as `tasks/<YYYY-MM-DD>-<short-slug>.md`. Tell the user the
   path, the confidence, and anything still open. Tell them `/spec-execute` runs it.

### Plan template

```markdown
# <Title>

- **Confidence:** <N>%
- **Branch:** new branch off `development`
- **Created:** <YYYY-MM-DD> by /spec-plan

## Problem
<One or two sentences.>

## Root cause / where it fits
<What the code does today and why, with file references.>

## Approach
<The chosen solution and why it is the simplest correct one. Rejected alternatives, one line each.>

## Steps
1. <One change> — `path/to/File.swift`

## Tests
<Tests to add or update, and how to run them.>

## Rules check
<One line per CLAUDE.md rule this plan touches, and how it complies.>

## Risks and open questions
<What keeps confidence below 100%.>

## Out of scope
<What this plan deliberately doesn't do.>
```
