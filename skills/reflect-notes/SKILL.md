---
name: reflect-notes
description: "Read, search, and open notes in Alex's Reflect graph (personal and work notes in one graph) via the `reflect` CLI. Use when he asks about his notes, daily notes, journal, meetings, or anything he may have written down in Reflect."
---

# Reflect notes

Reflect is a local-first, markdown-backed note app. All of Alex's notes,
personal and work, live in one graph synced through iCloud:

    $HOME/Library/Mobile Documents/iCloud~app~reflect/Documents/Notes

There is no separate work graph. Daily notes that hold work content group it
under a per-workplace `##` section (for example `## Arcade`, with `### Meetings`
inside it), below any personal bullets.

Read the graph through the `reflect` CLI rather than scanning files: it
resolves titles, aliases, and daily dates, searches the app's ranked index,
and enforces privacy.

## The CLI

Use `reflect` from PATH when available; otherwise the app bundles it at
`/Applications/Reflect.app/Contents/MacOS/reflect`. Always target the graph:

    reflect --graph "$HOME/Library/Mobile Documents/iCloud~app~reflect/Documents/Notes" <command>

or export `REFLECT_GRAPH` with that path for a sequence of calls.

    reflect today              # print today's daily note
    reflect today --path       # its absolute path (works before the file exists)
    reflect search <query>     # ranked full-text search over the graph
    reflect show <note>        # print a note by date, path, title, or alias
    reflect path <note>        # resolve a note to its absolute path
    reflect open <note>        # open the note in the Reflect app

- Add `--json` for stable machine-readable output.
- `<note>` resolves as `YYYY-MM-DD` date, graph-relative path, title, then alias.
- Exit codes: 0 ok, 1 runtime error, 2 usage error, 3 not found or private,
  4 search index missing (open the graph in Reflect once to build it).

## Git history

The graph root is a Git repository with a GitHub backup remote. Use Git only
for history, diffs, recovery, or past states:

    git -C "$HOME/Library/Mobile Documents/iCloud~app~reflect/Documents/Notes" log --oneline -- <graph-relative-path>

## Rules

1. **Respect privacy.** Notes with `private: true` frontmatter are hidden from
   the CLI. Don't read them from files or Git history unless Alex asks.
2. **The CLI never writes.** Notes are plain markdown (`daily/YYYY-MM-DD.md`,
   `notes/*.md`). To change one, edit the file `reflect path <note>` returns;
   the app picks the edit up. Add work items to the daily note's workplace
   section, and never reorder Alex's existing content.
3. **Prefer search over enumeration.** Use `reflect search`, not a grep of the
   whole graph.
