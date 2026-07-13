# claude-setup

Base personal setup for [Claude Code](https://claude.com/claude-code). Run by
`os/setup-mac.sh`, or standalone:

```
claude-setup/setup.sh
```

## What it does

1. **Installs Claude Code** if the `claude` command is missing (npm, or the
   official installer as a fallback).
2. **Seeds `~/.claude/settings.json`** from `claude/settings.json` — *no-clobber*.
   Claude Code mutates this file (via `/config`, plugin toggles), so it is a
   real file it owns, not a symlink into the repo. Edit `claude/settings.json`
   to change the baseline for future fresh machines.
3. **Symlinks your custom commands** (`claude/commands/*.md`) into
   `~/.claude/commands/`. These are static prompt files, so edits propagate
   back to the repo. Existing real files are backed up to `*.bak`.

## What is tracked

| Path | Why |
|------|-----|
| `claude/settings.json` | Global Claude Code settings (model, hooks, statusline, TUI). No secrets. |
| `claude/commands/*.md` | Personal slash commands: `merge`, `my-pr-review`, `pr-review-2`, `plan-exit-review`, `progress-update`, `review-outline-doc`. |

## What is deliberately NOT tracked (secret / runtime / machine-local)

`~/.claude.json` (auth), `history.jsonl`, `projects/` (transcripts),
`sessions/`, `settings.local.json` (per-machine permissions), all caches,
and the `plugins/` tree. A `.gitignore` here is a safety net against
accidentally committing any of them.

## GSD (get-shit-done) plugin

`settings.json` wires `SessionStart`/`PostToolUse` hooks and the status line to
the get-shit-done plugin (`~/.claude/hooks/gsd-*.js`). This setup **does not**
install plugins. On a fresh machine, either install GSD in Claude Code with
`/plugin`, or remove those hook entries from `~/.claude/settings.json` if you
don't use it — otherwise Claude Code will reference hook scripts that don't
exist.

> Note: paths in `settings.json` are absolute (`/Users/oojas/...`), so this
> reproduces cleanly on a machine with the same username.
