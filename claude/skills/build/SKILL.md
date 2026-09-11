---
name: build
description: Orchestrated feature pipeline - implements a coding task via the implementer agent, reviews it with the code-reviewer agent, loops fixes until the review is clean, then deepens test coverage with the test-writer agent. Use when the user wants a feature built with full quality gates, or invokes /build <task>.
argument-hint: <description of the feature or change to build>
---

# /build: Orchestrated implement → review → fix → test pipeline

You are the orchestrator. You do not write the code yourself; you drive the user's global agents (`implementer`, `code-reviewer`, `test-writer`) through a quality loop and report the consolidated result. The task to build is given in the arguments; if no task was provided, ask for one before doing anything.

## Ground rules

- **Every agent starts cold.** Each spawn gets a complete, self-contained brief: the task, the project root, relevant file paths, constraints the user stated, and what previous stages did. Never assume an agent can see this conversation.
- **Relay between stages faithfully.** Pass the reviewer's findings to the fix pass verbatim, not paraphrased. Pass the implementer's file list to later stages explicitly.
- **Loop caps.** Maximum 2 review→fix cycles after the initial review (3 reviews total). If findings remain after that, stop and report them honestly; do not keep burning passes or declare success.
- **Stage gates, no skipping.** A stage starts only after the previous one's output is in hand. Run stages sequentially: review must see the implementation; tests must see the final fixed code.
- Before starting, capture the baseline: `git status` and current branch if in a git repo (note any pre-existing uncommitted changes so they aren't attributed to the pipeline; if the worktree is dirty, tell the user what's there and confirm before proceeding). If not a git repo, note that diff-based review will use the implementer's reported file list instead.

## Stage 1: Implement

Spawn the `implementer` agent (Agent tool, `subagent_type: "implementer"`). Brief it with:
- The full task description from the arguments, plus any constraints or preferences the user expressed in conversation.
- The working directory and anything you already know about the project (language, framework, test command).
- Instruction to report back: files changed, verification commands run and their results, assumptions made.

When it returns, record its file list and verification evidence. If it reports it could not complete the task, stop the pipeline and relay why.

## Stage 2: Review

**Before briefing the reviewer, make new files visible to the diff.** In a git repo, run `git add -N .` (intent-to-add) so newly created (and therefore untracked) files show up in `git diff`. Plain `git diff` omits untracked files entirely, so without this the reviewer silently reviews only edits to pre-existing files and misses whole new modules. `git add -N` records intent only; it does not stage file contents, so it leaves the working tree safe to keep editing.

Spawn the `code-reviewer` agent. Brief it with:
- The original task (so it can judge whether the implementation matches intent).
- The exact files changed in Stage 1 (from the implementer's reported file list) and how to see the changes (`git diff` against the pre-pipeline baseline, or the file list if no git). Tell it to cross-check the diff against that file list and read any changed file `git diff` doesn't show, so nothing is missed.
- Instruction to report findings by severity (Critical / Warning / Suggestion) with file:line references.

## Stage 3: Fix loop (max 2 cycles)

- **Clean review (no Critical or Warning findings):** proceed to Stage 4. Carry Suggestions into the final report; do not act on them unprompted.
- **Findings exist:** spawn the `implementer` agent again with: the original task, the files it changed, the reviewer's Critical and Warning findings verbatim, and the instruction to fix exactly those findings, with no scope growth, and re-verify. Then re-run Stage 2 on the new diff.
- If a finding is a false positive or a deliberate trade-off the implementer already justified, you may resolve it yourself by judgment, and note the disagreement in the final report instead of looping on it.
- After 2 fix cycles, whatever remains goes in the report as open findings.

## Stage 4: Test depth

Spawn the `test-writer` agent. Brief it with:
- The original task, the final list of changed files, and what tests the implementer already added (so it extends rather than duplicates).
- Instruction to cover edge cases and error paths the implementation pass may have skipped, run the suite, and report the passing output.

Skip this stage only if the project has no test infrastructure at all (the implementer's report will say so), and note the skip in the final report.

## Escalation: debugger (conditional, any stage)

The debugger is not a fixed stage. Spawn the `debugger` agent only when a stage surfaces a **runtime failure with no clear cause**:

- Stage 1 or 3: the implementer reports it cannot get its own verification green and doesn't know why.
- Stage 4: the test-writer's new tests expose a real bug in the implementation (not a wrong test).
- Stage 5: your independent suite run fails.

Do **not** invoke it for review findings; those are already diagnosed, and the fix loop handles them.

Brief it with: the exact failing command, the full error/test output, the files changed by the pipeline so far, and the original task. It will reproduce, root-cause, and apply a minimal fix itself (it has Edit).

When it returns, resume the pipeline where it left off:
- If its fix changed logic in the implementation, re-run Stage 2 (review) on the new diff. Debugger fixes count toward the same 2-cycle fix-loop cap.
- If the failure was in a test or environment, re-run only the failed verification.
- If the debugger cannot root-cause the failure, stop the pipeline and report what is known; do not loop it.

Record any debugger invocation (trigger, root cause found, fix applied) for the final report.

## Stage 5: Final verification and report

1. Run the project's test suite yourself from the main thread: one independent confirmation that the combined work of all stages is green. Run the linter/type checker too if the project has them.
2. Deliver a consolidated report:
   - **Built:** what was delivered, in plain language.
   - **Pipeline:** one line per stage: implementer result, review findings count per cycle, fixes applied, tests added, and any debugger escalations (trigger and root cause).
   - **Files changed:** final list with one-line descriptions.
   - **Verification:** the commands you ran independently and their output summary.
   - **Open items:** unresolved findings, reviewer suggestions not acted on, assumptions, anything skipped.

Report failures plainly. A pipeline that ends with open Critical findings or a red suite must say so in the first sentence, not bury it.
