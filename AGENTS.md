# AGENTS.md — `_db_moma-collection`

This repository contains a **SQLite database builder** for the Museum of Modern Art (MoMA) collection data.

## Repository Summary

- **Purpose**: Build and maintain a local SQLite database from MoMA's collection repository
- **Source**: MoMA collection data from `collection/` submodule (git@github.com:MuseumofModernArt/collection.git)
- **Database**: `moma_full.db` (SQLite)
- **Builder**: `build_moma.py` (Python script)
- **Language**: Python

## Project Structure

```text
_db_moma-collection/
├── collection/              # Git submodule → MoMA collection repo
├── build_moma.py           # Database builder script
├── moma_full.db            # Generated SQLite database
└── AGENTS.md               # This file
```

## Git Submodule Notes

The `collection/` directory is a **git submodule** pointing to:
- **Repository**: `git@github.com:MuseumofModernArt/collection.git`
- **Configuration**: See `.gitmodules`

To update the submodule:
```bash
git submodule update --remote collection
```

## Engineering Notes

- Keep database schema decisions documented in code comments
- Preserve data integrity from source JSON/CSV files
- Log import progress and any data validation issues
- Do not modify files in `collection/` — it's a read-only submodule

## Workflow

1. Make surgical changes relevant to the request
2. Test database build with `python build_moma.py`
3. Validate schema and data integrity before finishing
4. Update AGENTS.md when behavior or architecture changes

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
