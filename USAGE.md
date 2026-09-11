# Usage guide

These are custom Claude Code agents and skills. This guide covers what each one
does, when to reach for it, and how to invoke it. For install steps see the
[README](README.md).

## Two kinds of tool: agents vs. skills

- **Agents** (in `claude/agents/`) are *subagents*: separate workers Claude
  launches with their own tool set and a clean context. You don't usually call
  them by name; you ask Claude to do something and it delegates, or you say
  "use the implementer agent to…". Each starts cold and reports back a result.
- **Skills** (in `claude/skills/`) are *workflows* you invoke directly by typing
  `/name` in the conversation. They run in your main session and can orchestrate
  several agents.

Rule of thumb: **skills are things you type; agents are things Claude delegates to.**

## Skills

### `/build <task>`: implement → review → fix → test pipeline
Builds a feature with quality gates instead of one-shotting it. It runs the
`implementer`, then `code-reviewer`, loops fixes until the review is clean
(max 2 fix cycles), then `test-writer` deepens coverage, and finally verifies the
suite itself. Use it for any non-trivial change you want done thoroughly.

```
/build add a parse_duration function that inverts format_duration
```
Best on a **git repo with a test suite**: the pipeline reviews the diff and runs
your tests. It leaves changes uncommitted for you to review. Overkill for
one-line tweaks; reach for it when correctness matters.

### `/rubber-duck <problem>`: Socratic planning partner
Helps *you* design a solution through guided questions instead of handing you
code. Use it before coding, when you're stuck on how to start, or want to think
an approach through. It writes no code; the plan is yours.

```
/rubber-duck how should I structure caching for the deck API?
```

## Agents

Invoke by describing the task, or explicitly: "use the `<name>` agent to…".

| Agent | Use it to… | Touches code? |
|-------|-----------|---------------|
| `implementer` | Build a feature end-to-end: explores the codebase, matches conventions, writes + verifies code | Yes |
| `test-writer` | Add tests, cover edge cases, fix a failing suite until green | Yes |
| `debugger` | Root-cause an error/crash/failing test and apply a minimal fix | Yes |
| `docs-writer` | Write/update READMEs, docstrings, changelogs to match the code | Docs only |
| `code-reviewer` | Review a diff/branch/file for bugs, security, maintainability | No (reports) |
| `teacher` | Understand code: explains a diff, file, or concept at your level | No |
| `git-mentor` | Prepare commits/PRs or untangle a git mess, explaining the why | No (git ops) |

**Doers vs. advisors:** the first four write code; the last three don't. The
advisors deliberately stay in their lane: the reviewer reports but won't fix,
the teacher explains but won't judge quality.

## Engineering guidelines

The code-writing agents are built around a shared standard; see
[`claude/engineering-guidelines.md`](claude/engineering-guidelines.md): think
before coding, keep it simple, make surgical changes, and verify against explicit
success criteria. That file is the source of truth and documents how the standard
is applied (and deliberately not applied) across the agents.

## Personalization: `learner-profile.md`

The `teacher` and `git-mentor` agents and the `rubber-duck` skill calibrate their
explanations to *you*. On first install, a template is copied to
`~/.claude/learner-profile.md`; edit it with your experience level, the languages
you know vs. are new to, and analogies that click for you. No profile? They fall
back to a sensible default. Everyone using these gets their own; nothing is
hardcoded to one person.

Your global `~/.claude/CLAUDE.md` "About me" section also feeds context to agents,
so keeping it current sharpens every agent, not just the three above.

## Tips

- **`/build` needs a test suite to shine.** On a repo without tests it skips the
  test-depth stage and says so.
- **Agents start cold.** They can't see your conversation; Claude briefs them, so
  the more specific your request, the better the brief.
- **Nothing auto-commits.** `/build` and the doer agents leave changes in your
  working tree for you to review and commit.
