# AGENTS.md — `_db_moma-collection`

This repository contains a **SQLite database builder** for the Museum of Modern Art (MoMA) collection data with **automatic rebuilding on updates**.

## Repository Summary

- **Purpose**: Build and maintain a local SQLite database from MoMA's collection repository
- **Source**: MoMA collection data from `collection/` submodule (git@github.com:MuseumofModernArt/collection.git)
- **Database**: `moma_full.db` (SQLite, tracked in git for submodule users)
- **Builder**: `build_moma.py` (Python script)
- **Auto-Update**: Git hook automatically rebuilds database on `git pull` when submodule changes
- **Language**: Python, Bash

## Project Structure

```text
_db_moma-collection/
├── collection/              # Git submodule → MoMA collection repo
│   ├── Artworks.json       # Source data (Git LFS, ~138MB)
│   ├── Artists.json        # Source data (Git LFS, ~3.4MB)
│   └── README.md           # MoMA's collection documentation
├── .githooks/              # Version-controlled git hooks
│   └── post-merge          # Auto-rebuild trigger
├── build_moma.py           # Database builder script
├── setup.sh                # One-time setup script (configures hooks)
├── moma_full.db            # Generated SQLite database (~72MB, tracked)
├── .gitignore              # Git ignore patterns
├── .gitmodules             # Submodule configuration
├── AGENTS.md               # This file (AI assistant context)
└── README.md               # User-facing documentation
```

## Git Submodule Notes

The `collection/` directory is a **git submodule** pointing to:
- **Repository**: `git@github.com:MuseumofModernArt/collection.git`
- **Configuration**: See `.gitmodules`

To update the submodule:
```bash
git submodule update --remote collection
git pull  # Triggers automatic rebuild via post-merge hook
```

## Automatic Rebuild System

### How It Works
1. User runs `git pull` (or merges changes)
2. Git executes `.githooks/post-merge` hook (if configured via `core.hooksPath`)
3. Hook detects if `collection/` submodule commit changed using `git diff-tree`
4. If changed, hook automatically:
   - Updates submodule files: `git submodule update --init --recursive`
   - Pulls LFS files: `git lfs pull` (in collection directory)
   - Rebuilds database: `python3 build_moma.py`
5. Database (`moma_full.db`) is regenerated with latest data
6. Changes are committed to track the updated database

### Setup for Distribution
The repository uses `core.hooksPath` to reference the `.githooks/` directory:
- **Version-controlled hooks**: `.githooks/post-merge` is committed to repo
- **Setup command**: `./setup.sh` runs `git config core.hooksPath .githooks`
- **No manual copying**: No need to copy hooks to `.git/hooks/`
- **Instant activation**: Works immediately after running `./setup.sh`
- **Per-repo config**: `core.hooksPath` is local to this repository only

### Why This Approach
- **Distribution-ready**: Hooks are committed, not local
- **Safe**: Hook errors don't fail git operations
- **Automatic**: No manual rebuild steps needed
- **Transparent**: Clear feedback when rebuilding occurs
- **Submodule-friendly**: Database file is tracked for parent repos

### Submodule Usage

When this repo is used as a submodule in a parent repository:

**What works:**
- ✅ Pre-built `moma_full.db` is available immediately (tracked in git)
- ✅ `build_moma.py` script can be run from parent repo
- ✅ Git hooks are isolated (don't affect parent repo)

**What doesn't work:**
- ❌ Automatic rebuilds (hooks only work in standalone mode)
- ❌ `setup.sh` isn't run automatically

**Parent repo example:**
```bash
# In parent repo, after submodule update
cd vendor/_db_moma-collection
python3 build_moma.py  # Rebuild if needed
cd ../..
```

## Engineering Notes

### Database Management
- **Schema**: Dynamically generated from JSON structure; decisions documented in code comments
- **Data integrity**: Preserve original data; all transformations are reversible or documented
- **File size**: Database is ~72MB; JSON sources are ~141MB total (138MB + 3.4MB)
- **Git tracking**: Database IS tracked in git (for submodule users who need immediate access)
- **Rebuild logic**: `build_moma.py` drops and recreates tables on each run

### Submodule Handling
- **Read-only**: Never modify files in `collection/` — it's a git submodule
- **Updates**: Use `git submodule update --remote collection` to fetch latest from MoMA
- **LFS files**: Require `git lfs pull` in collection directory to download full JSON files
- **Submodule commit**: Tracked in parent repo; changes trigger auto-rebuild

### Hook System
- **Detection method**: Uses `git diff-tree -r --name-only ORIG_HEAD HEAD` to detect submodule changes
- **Error handling**: Hook exits with 0 (success) even on errors to avoid breaking git operations
- **Isolation**: Hooks are repository-local; don't affect parent repos when used as submodule
- **Standalone only**: Automatic rebuilds only work when repo is cloned directly, not as submodule

### Workflow Best Practices
- Log import progress and data validation issues during build
- Test database integrity after rebuild: query record counts, check for NULL values
- When updating collection submodule, commit the updated database file
- Keep build times reasonable: current build takes ~10-30 seconds depending on hardware

## Development Workflow

### For AI Assistants Working on This Repo

1. **Understanding changes**: Review `build_moma.py` to understand data transformations
2. **Testing changes**: Always run `python3 build_moma.py` and verify output
3. **Database validation**: 
   - Check record counts match source data
   - Verify schema with `sqlite3 moma_full.db ".schema"`
   - Sample query: `SELECT COUNT(*) FROM artworks;` should return ~160,000
4. **Documentation updates**: Update AGENTS.md or README.md when behavior changes
5. **Commit strategy**: Commit database updates when collection submodule is updated

### Common Tasks

**Update to latest MoMA data:**
```bash
git submodule update --remote collection
cd collection && git lfs pull && cd ..
python3 build_moma.py
# Commit the updated database if satisfied
```

**Test the hook:**
```bash
# Verify hook is configured
git config --get core.hooksPath  # Should output: .githooks

# Manually trigger rebuild
python3 build_moma.py
```

**Validate database:**
```bash
sqlite3 moma_full.db "SELECT COUNT(*) FROM artworks;"  # ~160,000
sqlite3 moma_full.db "SELECT COUNT(*) FROM artists;"   # ~15,800
sqlite3 moma_full.db ".schema artworks" | head -10     # Show schema
```

---

# Global AI Agent Instructions

The following conventions apply across all my repositories. Project-specific rules above take precedence.

## About Me

- **Name**: Justin Johnso
- **GitHub**: justinjohnso, justinjohnso-itp, justinjohnso-tinker, justinjohnso-learn, justinjohnso-archive
- **Context**: NYU ITP graduate student; projects span physical computing, web development, creative coding, and embedded systems

---

## General Development Philosophy

1. **Clarity over cleverness** — code must be understandable by future-me and collaborators.
2. **Use working examples** as the basis for new code rather than writing from scratch.
3. **Event-driven, not polling** — prefer async patterns and notifications over busy-wait loops.
4. **Configuration in one place** — centralize constants; never duplicate magic numbers.
5. **Test early, test often** — write tests as you go, not as an afterthought.
6. **Commit as you go** — small, logical commits at each stable milestone.

---

## Quick Reference Commands

### Python Projects
```bash
python -m venv .venv && source .venv/bin/activate  # Create/activate venv
pip install -r requirements.txt                     # Install deps
pytest                                              # Run tests
black . && flake8                                   # Format & lint
```

### Git Workflow
```bash
git checkout -b feature/descriptive-name   # Feature branch
git add -p && git commit -m "type: msg"    # Stage interactively, commit
git push -u origin HEAD                    # Push and set upstream
```

---

## Code Conventions

### General
- **Naming**: `camelCase` for variables/functions, `PascalCase` for types/classes, `UPPER_CASE` for constants
- **Comments**: Sparingly — only for non-obvious logic or external constraints
- **Error handling**: Fail fast on init errors; return error types for recoverable failures
- **Logging**: Use structured logging with module-specific tags/prefixes

### Python
- Follow PEP 8; use `black` for formatting
- Type hints for function signatures
- Google-style docstrings for public APIs

---

## Project Structure Patterns

### Python Projects
```
src/
├── module_name/    # Main package
│   ├── __init__.py
│   └── ...
├── tests/          # Test files
├── requirements.txt
└── pyproject.toml
```

---

## Git Workflow & Branch Hygiene

1. **No direct feature work on `main`** — always use feature branches
2. **Branch naming**: `feature/`, `fix/`, `refactor/`, `docs/` prefixes
3. **Commit messages**: Use conventional commits format: `type(scope): description`
   - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
4. **Small, atomic commits** — one logical change per commit
5. **PR-first integration** — prefer merge via PR even for solo work
6. **Keep working trees clean** — commit or stash before context-switching

---

## Testing Requirements

- **All new logic requires tests** — this is non-negotiable
- **Test coverage**: Happy path + edge cases + error handling
- **Test naming**: Describe the behavior being tested
- **Mocking**: Mock external dependencies (APIs, databases, hardware)

### Frameworks by Language
| Language | Framework |
|----------|-----------|
| Python | pytest |

---

## Security Practices

- **No hardcoded secrets** — use environment variables exclusively
- **Input validation** — validate and sanitize all external input
- **Dependencies** — run `pip check` regularly
- **.env files** — never committed; always in `.gitignore`

---

## Documentation Standards

- **README.md** — every project needs one; current state, not changelog
- **AGENTS.md** — project-specific AI context (overrides global file)
- **Inline comments** — explain *why*, not *what*
- **API docs** — docstrings for public interfaces

---

## AI Assistant Guidelines

### When Working on My Code

1. **Ask clarifying questions** before making assumptions about ambiguous requirements
2. **Follow existing patterns** in the codebase over introducing new approaches
3. **Verify changes work** — run tests, build, lint before considering done
4. **DO NOT COMMIT** — never run `git commit` autonomously; I will review and commit manually
5. **DO NOT add Co-authored-by trailers** — if I ask you to draft a commit message, omit these entirely
6. **Update docs** if changes affect documented behavior

### Reference Repositories

Code in these GitHub organizations represents my canonical patterns:
- `github.com/justinjohnso`
- `github.com/justinjohnso-itp`
- `github.com/justinjohnso-tinker`
- `github.com/justinjohnso-learn`

When in doubt, check existing projects for established patterns.

---

## Preferred Tools & Libraries

| Category | Preference |
|----------|------------|
| Formatter (Python) | black |
| Linter (Python) | flake8, pylint |
| Version control | Git (with conventional commits) |

---

*Last updated: March 2026*
