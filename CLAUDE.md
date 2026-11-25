# CLAUDE.md

How to work in this repository. Keep it lean.

## What this is

**JonContextMenu** — a long-press arc menu for iOS (like Pinterest's). The user presses a view,
items fan out around the finger, and they drag to one and lift to select it. A small, dependency-free
Swift package with a UIKit API and a SwiftUI modifier.

- Swift 6 language mode, strict concurrency. iOS 15+.
- Swift Package Manager only. No CocoaPods, Carthage, or Objective-C support.
- Zero third-party dependencies. Ask before adding one.

## Architecture

The code is split into **pure logic** and a **thin UIKit layer**. That is the whole architecture —
don't add layers, coordinators, view models, or containers on top of it.

| Folder | Owns | Must not contain |
|---|---|---|
| `Sources/JonContextMenu/Public/` | The entire public API: item model, style, `UIInteraction`, SwiftUI modifier | Layout math, touch logic |
| `Sources/JonContextMenu/Layout/` | Where items and the title go, given touch point, bounds, and item count | `import UIKit`, views, animation |
| `Sources/JonContextMenu/Interaction/` | The touch state machine: which item is highlighted, when to select or dismiss | `import UIKit`, views |
| `Sources/JonContextMenu/Views/` | Drawing and animating what Layout and Interaction decided | Decisions: math or state rules |
| `Tests/JonContextMenuTests/` | Unit tests for `Layout/` and `Interaction/` | — |
| `Example/` | A demo app that uses the package | Library code |

- `Layout/` and `Interaction/` are plain value types and `Sendable`. They import Foundation/CoreGraphics only,
  so they are fully unit-testable.
- Views are `internal`. Clients only see `Public/`.
- The window is read from the pressed view when the menu opens — never `keyWindow`, never `UIScreen.main`.

## Non-negotiable

- **Simplest correct solution wins.** If a piece of logic is hard to explain in one or two sentences,
  stop and redesign it before writing more.
- **No hacks or workarounds.** No `DispatchQueue.main.asyncAfter` to "fix" timing, no magic offsets
  to make something line up, no catching and ignoring a problem. If the code is heading that way, stop,
  find the root cause, and revise the design.
- No force unwrap, `try!`, or `as!`. No `fatalError` in reachable code.
- No `nonisolated(unsafe)`, `@unchecked Sendable`, or `@preconcurrency` to silence the compiler.
  UIKit-facing types are `@MainActor`.
- No magic numbers. Sizes, distances, and timings live in named constants or `ArcMenuStyle`.
- Public API is minimal and deliberate: `public`, never `open`. Value types by default; `class` only
  where UIKit requires it.
- Priority when these conflict: **Correctness → Simplicity → Readability → Performance.**

## Comments

Code explains itself through names. **The default is no comment.**

A comment is allowed only to give context that the code cannot show, or to explain unavoidable
non-obvious logic (e.g. a coordinate-space quirk). One short line. Never:

- restate what the code or the name already says (`/// The title of the item`)
- narrate history, alternatives, or decisions ("we used to…", "instead of X…")
- leave commented-out code, TODOs without an owner, or ticket references
- add doc comments to `internal`/`private` members just to have them

Public API gets a brief doc comment only when usage isn't obvious from the signature.

## Testing

- Every rule in `Layout/` and `Interaction/` has a unit test. Views are verified in the Example app.
- Tests use Swift Testing, are deterministic, test one behavior each, and have a display name that
  states the behavior (`@Test("Near the left edge, items fan out to the right")`).
- The package is iOS-only, so `swift build` on macOS won't work. Run tests with
  `xcodebuild test -scheme JonContextMenu -destination 'platform=iOS Simulator,name=<device>' -parallel-testing-enabled NO`.

## Git workflow

- `main` is protected and holds released code only. Never commit to it directly.
- All work branches off `development` and goes back through a PR into `development`.
- Release: open a PR `development` → `main`, merge it, then tag `main` with a semantic version
  (`2.0.0`) and create the GitHub release from that tag.
- One logical change per commit and per PR. Don't mix a refactor with a behavior change.
- Conventional commits: `feat(layout): place items away from screen edges`, `fix(interaction): …`,
  `chore(spm): …`, `docs(readme): …`, `test(layout): …`.

## How work gets done

- Plan before multi-file or architectural changes and explain the approach first.
- Change the minimum code needed. Don't tidy unrelated code in the same diff.
- Surface any architectural decision and its tradeoff — never make one silently.
- After implementing, briefly say why this approach and what was rejected.

## Spec workflow

- `/spec-plan <problem>` — a fresh Opus session plans against `origin/development`. The plan is saved to
  `tasks/` only after it passes every readiness gate and an independent review, at 80%+ confidence.
- `/spec-execute [plan]` — a fresh Sonnet session implements a ready plan, checks the diff against it,
  opens a PR into `development`, and deletes the plan. If it can't follow the plan, it marks the plan
  blocked instead of improvising.
- `/spec-review <what's wrong>` — an Opus session reviews what `/spec-execute` did and saves a fix plan
  to `tasks/`.

`tasks/` is git-ignored: plans are working files, and each executed plan is kept in its PR's body.
