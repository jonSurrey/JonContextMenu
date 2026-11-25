---
name: spec-review
description: Reviews work done by /spec-execute against a problem the user describes, in a dedicated Opus (medium effort) session, and saves a fix plan to tasks/. Invoke via "/spec-review <what's wrong> [PR number]".
argument-hint: <what's wrong with the executed work> [PR number]
disable-model-invocation: true
---

# /spec-review

What the user reports: **$ARGUMENTS**

If nothing was reported, ask the user what to review and stop.

Section 1 runs in the session where the user typed the command. Section 2 runs in the Opus
session that section 1 hands the work to. Never review in the invoking session.

## 1. Hand off to an Opus medium session

Follow section 1 of `.claude/skills/spec-plan/SKILL.md`, with two changes:

- the title is `Spec review: <short problem>`;
- the brief is:

  > Follow section 2 of `<repo>/.claude/skills/spec-review/SKILL.md` to review: <user's report>.
  > Save the plan in `<repo>/tasks/`.

## 2. Review (in the Opus session)

Read `CLAUDE.md` first. Change no source code here.

1. **Find the executed work.** If the report names a PR or branch, use it. Otherwise, take the most
   recent PR whose body contains the line `Executed from a /spec-plan plan`, using
   `gh pr list --state all --search "Executed from a /spec-plan plan in:body"`. Tell the user
   which PR you picked.
2. **Read** that PR's diff, its plan section, and its listed deviations.
3. **Find the cause** of what the user reports, and say which of these it is:
   - the plan was wrong or incomplete;
   - the execution didn't follow the plan;
   - the user is asking for something new.
4. **Plan the fix.** Follow steps 2–6 of section 2 of `.claude/skills/spec-plan/SKILL.md`, with
   your findings as the problem, and hold it to the same 80% confidence bar. In the plan header:
   - **Branch:** the PR's branch if the PR is still open, otherwise a new branch off `development`;
   - add a line `- **Follows up:** PR #<number>`.
5. **Save** the plan in `tasks/`. Tell the user the path, what you found in step 3, and that
   `/spec-execute` runs it.
