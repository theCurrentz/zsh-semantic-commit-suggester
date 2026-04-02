typeset -g _SEMANTIC_COMMIT_CACHE_DIR=
typeset -g _SEMANTIC_COMMIT_CACHE_BRANCH=
typeset -g _SEMANTIC_COMMIT_CACHE_PREFIX=

_git_is_commit_command() {
  local buffer="$1"
  [[ "$buffer" =~ '^(git[[:space:]]+commit|gc)([[:space:]].*)?-m[[:space:]]+"[^"]*$' ]] && return 0
  [[ "$buffer" =~ $'^(git[[:space:]]+commit|gc)([[:space:]].*)?-m[[:space:]]*\'[^\']*$' ]] && return 0
  return 1
}

_git_extract_commit_message() {
  local buffer="$1"
  if [[ "$buffer" =~ '-m[[:space:]]+"([^"]*)$' ]]; then
    echo -E "${match[1]}"
    return 0
  fi
  if [[ "$buffer" =~ $'-m[[:space:]]*\'([^\']*)$' ]]; then
    echo -E "${match[1]}"
    return 0
  fi
  return 1
}

_git_semantic_type_from_branch() {
  local b="$1" seg
  [[ "$b" == */* ]] && seg="${b%%/*}" || seg="${b%%-*}"
  seg="${seg:l}"
  case "$seg" in
    feature) echo feat; return ;;
    bugfix|hotfix) echo fix; return ;;
  esac
  [[ "$seg" == (feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert) ]] && echo "$seg"
}

_git_ticket_from_branch() {
  local b="$1" rest
  # Strip the type prefix (everything up to and including the first / or -)
  [[ "$b" == */* ]] && rest="${b#*/}" || rest="${b#*-}"
  # Match Jira-style ticket: PROJECT-123 at the start of the remainder
  # PROJECT must be all-alpha (case-insensitive), followed by -DIGITS
  if [[ "$rest" =~ '^([A-Za-z]+-[0-9]+)(-|$)' ]]; then
    echo "${match[1]:l}"
  fi
}

_git_build_prefix() {
  local dir="${PWD:A}" branch prefix type ticket
  git rev-parse --is-inside-work-tree &>/dev/null || return 1
  branch=$(git symbolic-ref -q --short HEAD 2>/dev/null) || return 1
  if [[ "$dir" == "$_SEMANTIC_COMMIT_CACHE_DIR" && "$branch" == "$_SEMANTIC_COMMIT_CACHE_BRANCH" && -n "$_SEMANTIC_COMMIT_CACHE_PREFIX" ]]; then
    echo -E "$_SEMANTIC_COMMIT_CACHE_PREFIX"
    return 0
  fi
  # Invalidate cache before recomputing
  _SEMANTIC_COMMIT_CACHE_DIR=
  _SEMANTIC_COMMIT_CACHE_BRANCH=
  _SEMANTIC_COMMIT_CACHE_PREFIX=
  type=$(_git_semantic_type_from_branch "$branch") || return 1
  ticket=$(_git_ticket_from_branch "$branch")
  if [[ -n "$ticket" ]]; then
    prefix="${type}(${ticket}): "
  else
    prefix="${type}: "
  fi
  _SEMANTIC_COMMIT_CACHE_DIR="$dir"
  _SEMANTIC_COMMIT_CACHE_BRANCH="$branch"
  _SEMANTIC_COMMIT_CACHE_PREFIX="$prefix"
  echo -E "$prefix"
}

_zsh_autosuggest_strategy_git_commit_prefix() {
  local buffer="$1" typed prefix
  _git_is_commit_command "$buffer" || return 1
  typed=$(_git_extract_commit_message "$buffer") || return 1
  prefix=$(_git_build_prefix) || return 1
  [[ "$prefix" == "$typed"* ]] || return 1
  [[ "$prefix" == "$typed" ]] && return 1
  typeset -g suggestion="${buffer}${prefix#$typed}"
}
