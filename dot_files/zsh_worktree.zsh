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

# gwtrm [branch] - remove the worktree at <branch>, then delete the branch.
#                  No argument: pick one with fzf. The main worktree is never offered.
#                  Uses safe `git worktree remove` / `git branch -d`: dirty worktrees
#                  and unmerged branches are refused, not force-deleted.
gwtrm() {
  git rev-parse --git-dir >/dev/null 2>&1 || { print -u2 "gwtrm: not a git repository"; return 1 }

  local main line branch target
  main=$(_gwt_list | head -1 | cut -f2)
  if [[ -n $1 ]]; then
    line=$(_gwt_list | tail -n +2 | awk -F'\t' -v b="$1" '$1 == b { print; exit }')
    [[ -n $line ]] || { print -u2 "gwtrm: no removable worktree at '$1'"; return 1 }
  else
    (( $+commands[fzf] )) || { print -u2 "gwtrm: usage: gwtrm <branch>"; return 1 }
    line=$(_gwt_list | tail -n +2 | fzf --height 40% --reverse --delimiter='\t' \
                                        --with-nth=1,2 --prompt='remove worktree> ')
    [[ -n $line ]] || return 130
  fi
  branch=${line%%$'\t'*} target=${line#*$'\t'}

  # Can't remove the worktree we're standing in.
  [[ $PWD/ == $target/* ]] && cd -- "$main"

  git worktree remove -- "$target" || return
  [[ $branch == "(detached)" ]] || git branch -d -- "$branch" ||
    print -u2 "gwtrm: branch kept; force delete with: git branch -D $branch"
}

_gwtrm() { compadd -a -- "${(@f)$(_gwt_list | tail -n +2 | cut -f1)}" }
if (( $+functions[compdef] )); then
  compdef _gwtrm gwtrm
fi
