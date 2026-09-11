# dotfiles

My personal [Claude Code](https://claude.ai/code) configuration (custom subagents and skills) kept in version control so every machine I work on shares the same setup.

## What's in here

```
claude/
  agents/            # subagents: launched via the Agent tool
    implementer.md       full-cycle production coding
    code-reviewer.md     read-only review by severity
    test-writer.md       writes tests, iterates to green
    debugger.md          reproduce -> root-cause -> minimal fix
    docs-writer.md       docs/comments only, never logic
    teacher.md           explains code (read-only tutoring)
    git-mentor.md        runs git AND teaches the why
  skills/            # skills: invoked with /name in a conversation
    build/           /build: orchestrates implementer -> reviewer -> fix loop -> test-writer
    rubber-duck/     /rubber-duck: Socratic planning partner, no code
```

These files are self-contained: the agents embed their own guideline text, so no plugins or `settings.json` changes are required to use them.

**New here? See [USAGE.md](USAGE.md)** for what each agent and skill does, when to reach for it, and how to invoke it.

## Personalizing the teacher agent

The `teacher` agent tailors its explanations to whoever is using it. It reads a
learner profile from `~/.claude/learner-profile.md`: your experience level, which
languages you know versus are new to, and analogies that work for you. The install
script drops a template there on first run (from [`learner-profile.example.md`](learner-profile.example.md));
edit it to make the teacher explain things at your level. No profile? The teacher
falls back to a sensible default. This file is **not** in the repo; it's personal
to each machine/person, so everyone using these agents gets their own.

## Install on a new machine

Clone the repo, then run the install script for that OS. It copies the files into
`~/.claude/agents/` and `~/.claude/skills/`, backing up any existing file it would
overwrite to `<file>.bak`.

**Mac / Linux:**
```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh          # or: bash install.sh
```

**Windows:**
```powershell
git clone <your-repo-url> $HOME\dotfiles
cd $HOME\dotfiles
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Restart Claude Code (or run `/agents`) afterward to pick up the changes.
