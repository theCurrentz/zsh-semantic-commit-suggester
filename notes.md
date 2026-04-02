# Notes

- The default agent image did not include `zsh`; it was installed with `apt` to run smoke checks against `semantic-commit-autosuggest.zsh`. End users already have Zsh.
- `-m 'single-quoted'` messages are intentionally unsupported (PRD §5.5 / optional future pattern).
- Manual validation: `_git_commit_prefix_suggest` returns `feat: ` on a `feat/...` branch with `BUFFER='git commit -m "'` and `CURSOR` at end; detached `HEAD` returns no suggestion; wrong type prefix (e.g. `fix` on `feat/...`) returns no suggestion.
