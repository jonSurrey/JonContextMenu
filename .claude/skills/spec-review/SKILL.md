---
name: spec-review
description: Reviews work done by /spec-execute against a problem the user describes, in an Opus (medium effort) session, and saves a fix plan to tasks/. It reuses the session that planned the original work when that session is still fit; otherwise it starts a fresh one. Invoke via "/spec-review <what's wrong> [PR number]".
argument-hint: <what's wrong with the executed work> [PR number]
disable-model-invocation: true
---

# /spec-review

What the user reports: **$ARGUMENTS**

If nothing was reported, ask the user what to review and stop.

Section 1 runs in the session where the user typed the command. Section 2 runs in the Opus
session that section 1 hands the work to. Never review in the invoking session.

## 1. Hand off to an Opus medium session

1. Do steps 1–2 of section 1 of `.claude/skills/spec-plan/SKILL.md`: the desktop app check, and
   the check that this session is on Opus at medium effort or higher.
2. **Find the executed work.** If the report names a PR or branch, use it. Otherwise, take the most
   recent PR whose body contains the line `Executed from a /spec-plan plan`, using
   `gh pr list --state all --search "\"Executed from a /spec-plan plan\" in:body"`. If none is
   found, tell the user and stop.
3. **Reuse the planning session if it is still fit.** Read **Planned in session** from the plan in
   that PR's body. Reuse that session only if all of these hold:
   - it still exists and isn't archived;
   - `get_session` reports an Opus model and `medium` effort;
   - it is not in the middle of a turn;
   - `get_usage(session_id)` reports its context window and it is **under 50% full**. If usage is
     unavailable, don't reuse it.
4. Send the brief below:
   - **Planning session fit:** `send_message` to it.
   - **Otherwise:** `start_session` with the same settings as step 3 of section 1 of
     `.claude/skills/spec-plan/SKILL.md`, but `title: "Spec review: <short problem>"`.
5. Link the session, say which PR it reviews, and end your turn.

Brief, with absolute paths filled in:

> Follow section 2 of `<repo>/.claude/skills/spec-review/SKILL.md` to review PR #<number> for:
> <user's report>. Save the plan in `<repo>/tasks/`.

## 2. Review (in the Opus session)

Read `CLAUDE.md` first. Change no source code here.

1. **Check out the work.** Run `git fetch origin`, then switch to a detached copy of the PR's head
   (`gh pr checkout <number> --detach`).
2. **Read** that PR's diff, its plan section, its **Plan check**, and its listed deviations.
3. **Find the cause** of what the user reports, confirmed in the code with `file:line` references,
   and say which of these it is:
   - the plan was wrong or incomplete;
   - the execution didn't follow the plan;
   - the user is asking for something new.
4. **Plan the fix.** Follow steps 2–7 of section 2 of `.claude/skills/spec-plan/SKILL.md`, with
   your findings as the problem. The same readiness gates, independent review and 80% confidence
   bar apply. In the plan header:
   - **Based on:** the PR's head branch @ its head commit;
   - **Branch:** the PR's branch if the PR is still open, otherwise a new branch off `development`;
   - add a line `- **Follows up:** PR #<number>`.
5. Tell the user the plan's path, what you found in step 3, and that `/spec-execute` runs it.
