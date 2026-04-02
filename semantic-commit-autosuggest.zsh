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
  local b="$1" seg kind
  [[ "$b" == */* ]] && seg="${b%%/*}" || seg="${b%%-*}"
  seg="${seg:l}"
  case "$seg" in
    feature) echo feat; return ;;
    bugfix|hotfix) echo fix; return ;;
  esac
  [[ "$seg" == (feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert) ]] && echo "$seg"
}

_git_build_prefix() {
  local dir="${PWD:A}" branch prefix type
  git rev-parse --is-inside-work-tree &>/dev/null || return 1
  branch=$(git symbolic-ref -q --short HEAD 2>/dev/null) || return 1
  if [[ "$dir" == "$_SEMANTIC_COMMIT_CACHE_DIR" && "$branch" == "$_SEMANTIC_COMMIT_CACHE_BRANCH" && -n "$_SEMANTIC_COMMIT_CACHE_PREFIX" ]]; then
    echo -E "$_SEMANTIC_COMMIT_CACHE_PREFIX"
    return 0
  fi
  type=$(_git_semantic_type_from_branch "$branch") || return 1
  prefix="${type}: "
  _SEMANTIC_COMMIT_CACHE_DIR="$dir"
  _SEMANTIC_COMMIT_CACHE_BRANCH="$branch"
  _SEMANTIC_COMMIT_CACHE_PREFIX="$prefix"
  echo -E "$prefix"
}

_git_commit_prefix_suggest() {
  local buffer="$BUFFER" typed prefix suffix
  [[ $CURSOR -ne ${#BUFFER} ]] && return 1
  _git_is_commit_command "$buffer" || return 1
  typed=$(_git_extract_commit_message "$buffer") || return 1
  prefix=$(_git_build_prefix) || return 1
  [[ "$prefix" == "$typed"* ]] || return 1
  suffix="${prefix#$typed}"
  [[ -n "$suffix" ]] || return 1
  echo -E "$suffix"
  return 0
}
