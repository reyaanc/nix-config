# Running commands

I run you with few permission prompts. That only works if you treat anything that changes state outside this checkout as mine to run.

Never run a command that applies changes to shared or remote state, even when it's the last step of the task:

- `git push`, `git commit`, `git add`
- `terraform`/`tofu` `apply`, `destroy`, `import`, or any `state` mutation
- `kubectl apply/create/delete/patch/edit/scale/rollout restart`, `helm install/upgrade/uninstall/rollback`
- `aws` commands that create, update, delete, put, invoke, or upload anything
- `docker push`, `npm publish`, `cargo publish`, `uv publish`
- `gh pr create/merge/close/comment/review`, `gh issue create/comment`, `gh release`, `gh workflow run`
- `darwin-rebuild`, `nixos-rebuild`, `home-manager` or `nh` `switch`
- Deploy scripts and `make`/`npm`/`just` targets that deploy, release, or migrate a real database

Do the read-only half instead and hand me the rest: `terraform plan`, `kubectl diff`, `helm template`, `aws ... describe/list`, `nix build`. End with the exact command for me to run.

A denied command is a decision, not an obstacle. Don't rephrase it, wrap it in a script, chain it behind `uv run`/`nix develop -c`/`sh -c`, or reach it through another tool.

## Tips

- Use the LSP tool for definitions, references, and type info before grepping a large codebase. Fall back to `rg` when no server covers the language.
- `rg` and `fd` over `grep` and `find`.
- Run the narrowest check that proves the change: one test, one crate, one file. Widen only once that passes.
- If the repo's CLAUDE.md, README, Makefile, justfile, or CI workflow defines how to build and test, use that over generic commands.
- Repos with `flake.nix` and `.envrc` get their toolchain from direnv. A missing tool usually means the dev shell isn't loaded; use `nix develop -c <cmd>`.
- Never install tools globally (`brew install`, `pip install --user`, `npm -g`, `cargo install`). Tell me what's missing and I'll add it to nix.
- Long-running servers and watchers go in the background, never the foreground.
- A sandbox denial on a path or host is information. Say what was blocked instead of hunting for another route to it.
