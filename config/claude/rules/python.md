---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
---
Python lets you get away with anything, so the structure has to come from you.

- Everything goes through uv: `uv run pytest`, `uv run python`, `uv add`. Never `pip install`, never the system interpreter.
- `uv run ruff check --fix` and `uv run ruff format` on the files you changed. Type check with basedpyright or pyright if the project configures one.
- Type hints on signatures. Don't annotate locals the checker can infer.
- `pathlib` over `os.path`, f-strings over `%` and `.format`, dataclasses over dicts with known keys.
- Imports at the top. Inside a function only to break a real import cycle.
- No `sys.path` hacks.
