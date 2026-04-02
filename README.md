# zsh-semantic-commit-suggester

[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) strategy that suggests a Conventional Commits style prefix (`feat: `, `fix: `, etc.) from the current branch name when you type `git commit ... -m "` or `gc ... -m "` (Oh My Zsh).

## Install

Clone or copy `semantic-commit-autosuggest.zsh` onto your machine and source it **after** zsh-autosuggestions:

```zsh
source /path/to/zsh-autosuggestions.zsh
source /path/to/semantic-commit-autosuggest.zsh
ZSH_AUTOSUGGEST_STRATEGY=(
  git_commit_prefix
  history
)
```

Keep `_git_commit_prefix_suggest` before `history` so branch-based text is tried first; history fills in when there is no prefix suggestion.

## Behavior

- Suggests only the **missing** characters after the opening double quote (e.g. `feat: ` on a `feat/...` branch).
- No suggestion outside a git work tree, or on detached `HEAD`.
- Caches the last computed prefix per directory and branch so `git` is not run on every keystroke.
- Double-quoted messages: `... -m "…` (space before `"` as in the usual form).
- Single-quoted messages: `... -m'…` or `... -m '…` (optional space before `'`).

## Branch → type

The first path segment (e.g. `feat/foo` → `feat`) or first segment before `-` on a flat name is lowercased and mapped: `feature` → `feat`, `bugfix` / `hotfix` → `fix`. If it is already a known Conventional Commits type (`feat`, `fix`, `docs`, …), that value is used. Otherwise no prefix is suggested.

## License

GPL-3.0 — see [LICENSE](LICENSE).
