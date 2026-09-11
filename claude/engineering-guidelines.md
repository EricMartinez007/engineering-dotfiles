# Engineering Guidelines

The shared engineering standard these agents and skills are built around. Four
principles, in priority order. They exist to counter the usual failure modes of
LLM-written code: overcomplication, silent assumptions, unrequested changes, and
"done" that was never actually verified.

## 1. Think before coding

State assumptions explicitly. If a request has multiple reasonable
interpretations, surface them instead of silently picking one. If a simpler
approach than the one asked for exists, say so. When something is unclear, name
the confusion and ask rather than guessing.

## 2. Simplicity first

The minimum that solves the problem. No features beyond what was asked, no
abstractions for single-use code, no speculative flexibility or configurability
nobody requested, no error handling for impossible states. If a senior engineer
would call it overcomplicated, simplify.

## 3. Surgical changes

Touch only what the task requires. Don't improve adjacent code, comments, or
formatting; don't refactor what isn't broken; match the existing style even if
you'd do it differently. Remove orphans your own changes created, but only
*mention* pre-existing dead code; don't delete it. Every changed line should
trace directly to the request.

## 4. Goal-driven execution

Define verifiable success criteria up front, state a brief step -> verify plan,
and loop until it's actually met. "Make it work" is not a criterion; "test X
passes and command Y prints Z" is. Never report success on an unverified result.

## How these are applied across the agents

This file is the source of truth for the concepts. The agents do **not** read it
at runtime (subagents can't import files and start with only their own prompt),
so the guidelines are embedded directly where they're needed:

- **Code-writing agents** (`implementer`, `test-writer`, `debugger`,
  `docs-writer`) embed a copy of these principles, adapted to their role (e.g.
  the test-writer's version speaks in terms of test code). **When you change a
  principle here, update those inline copies too.**
- **Advisory agents** (`code-reviewer`, `teacher`, `git-mentor`) do not carry
  the block, by design. Principles 2 and 3 are about *writing* code, which these
  agents don't do; principles 1 (think first) and 4 (verifiable goals) are
  already built into their own instructions. This exemption is deliberate, not an
  oversight.
