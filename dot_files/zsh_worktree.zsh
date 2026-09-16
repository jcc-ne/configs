# --- git worktree navigation ---
# `git wt` (alias for `git worktree`) can't cd for you: a git subprocess can't
# change its parent shell's directory. So branch -> worktree navigation lives
# here as a shell function.

# Emit "<branch>\t<path>" per worktree; detached heads show as "(detached)".
_gwt_list() {
  git worktree list --porcelain 2>/dev/null | awk '
    /^worktree /  { path = substr($0, 10) }
    /^branch /    { br = substr($0, 8); sub("^refs/heads/", "", br); print br "\t" path }
    /^detached$/  { print "(detached)\t" path }
  '
}

# gwt [branch]  - cd to the worktree checked out at <branch>.
#                 No argument: pick one with fzf (or just list if fzf is absent).
gwt() {
  git rev-parse --git-dir >/dev/null 2>&1 || { print -u2 "gwt: not a git repository"; return 1 }

  local branch=$1 target
  if [[ -z $branch ]]; then
    if (( $+commands[fzf] )); then
      target=$(_gwt_list | fzf --height 40% --reverse --delimiter='\t' \
                               --with-nth=1,2 --prompt='worktree> ' | cut -f2)
      [[ -n $target ]] || return 130
    else
      _gwt_list | column -t -s $'\t'
      return 0
    fi
  else
    target=$(_gwt_list | awk -F'\t' -v b="$branch" '$1 == b { print $2; exit }')
    if [[ -z $target ]]; then
      print -u2 "gwt: no worktree checked out at '$branch'. Existing worktrees:"
      _gwt_list | column -t -s $'\t' | sed 's/^/  /' >&2
      if git show-ref --verify --quiet "refs/heads/$branch"; then
        print -u2 "gwt: branch exists but has no worktree; create one with:"
        print -u2 "  git wt add ../${branch:t} $branch"
      fi
      return 1
    fi
  fi

  cd -- "$target"
}

# Complete on branches that actually have a worktree.
_gwt() { compadd -a -- "${(@f)$(_gwt_list | cut -f1)}" }
if (( $+functions[compdef] )); then
  compdef _gwt gwt
fi
