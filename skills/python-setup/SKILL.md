---
name: python-setup
description: Set up a sandbox-safe Python environment for a project — reuse an existing interpreter/venv if present, else create a project-local venv. Use when `python` is missing, pip installs fail under the sandbox, or a project needs an isolated interpreter.
---

# Python Setup

macOS no longer ships `python` (only `python3`), and the system/framework interpreter's `site-packages` plus the default pip cache (`~/Library/Caches/pip`) sit outside the sandbox's writable paths — so `pip install` fails there. The fix is a project-local virtual environment with its cache on a writable path.

## Reuse before creating
First check whether the project already has an interpreter, and use it rather than reinstalling:
- An existing `.venv/` or `venv/` in the repo → use `.venv/bin/python`.
- An IDE-configured interpreter (JetBrains/WebStorm/PyCharm: look in `.idea/`, or a `.venv` the IDE made) → use that path.
- A `.python-version` (pyenv) or `.tool-versions`/`.mise.toml` pin → honor it.

Only run the setup below when none of these exist.

## Default path — project venv

Run from the project root (all paths below are sandbox-writable):

```bash
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/pip install -r requirements.txt   # if present
```

Then always invoke through the venv — `.venv/bin/python` and `.venv/bin/pip` — never bare `python`/`pip`. This gives you a real `python`, isolates dependencies per project, and writes only inside the repo.

- Add `.venv/` to the project's `.gitignore` if it isn't already covered.
- If pip still tries to write `~/Library/Caches/pip`, set `PIP_CACHE_DIR="$PWD/.venv/.pip-cache"` (under the repo) or pass `--no-cache-dir`.

## When a specific Python version is needed — pyenv

`~/.pyenv` is already in the sandbox `allowWrite` list, so pyenv installs cleanly:

```bash
pyenv install 3.12.4        # if that version isn't installed yet
pyenv local 3.12.4          # writes .python-version in the repo
python3 -m venv .venv       # then the venv flow above
```

## Notes
- Don't `pip install` into the system/framework interpreter — it fails under the sandbox and pollutes a shared environment.
- If a tool must run unsandboxed (e.g. needs a host network DB), say so and have the user run it via the `!` prefix rather than weakening the sandbox.
