#!/bin/sh
# Claude Code status line script

input=$(cat)

# Parse all fields in a single jq call
eval "$(echo "$input" | jq -r '
  "cwd=\(.workspace.current_dir // .cwd // "")",
  "project_dir=\(.workspace.project_dir // "")",
  "model=\(.model.display_name // "")",
  "total_in=\(.context_window.total_input_tokens // "")",
  "total_out=\(.context_window.total_output_tokens // "")",
  "current_in=\(.context_window.current_usage.input_tokens // "")",
  "current_out=\(.context_window.current_usage.output_tokens // "")",
  "cache_read=\(.context_window.current_usage.cache_read_input_tokens // "")",
  "cache_write=\(.context_window.current_usage.cache_creation_input_tokens // "")",
  "ctx_window_size=\(.context_window.context_window_size // "")",
  "ctx_used_pct=\(.context_window.used_percentage // "")"
' | sed 's/"/\\"/g; s/=\(.*\)/="\1"/')"

# ANSI colors
R="\033[0m"; DIM="\033[2m"
YELLOW="\033[33m"; GREEN="\033[32m"; CYAN="\033[36m"; MAGENTA="\033[35m"; BLUE="\033[34m"
SEP="${DIM} | ${R}"

# Icons (update these to your preferred glyphs)
ICON_PROJ=$(printf '\xf3\xb1\x9c\xa4')
ICON_CWD=$(printf '\xf3\xb0\x9d\xb0')
ICON_GIT=$(printf '\xef\x84\xa6')
ICON_CTX=$(printf '\xef\x80\xbe')
ICON_TOKEN=$(printf '\xee\xb7\xa8')
ICON_CACHE=$(printf '\xef\x92\x9b')

# Format token count with k suffix
fmtk() { [ "$1" -ge 1000 ] 2>/dev/null && echo "$((${1} / 1000))k" || echo "$1"; }

# Relative path from project_dir to cwd
rel_path=""
[ -n "$project_dir" ] && [ -n "$cwd" ] && [ "$cwd" != "$project_dir" ] && \
  rel_path=$(echo "$cwd" | sed "s|^${project_dir}/||")

# Git branch
git_branch=""
git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1 && \
  git_branch=$(git -C "$cwd" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null || \
               git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

# Project name
proj_name=$(basename "${project_dir:-$cwd}")

# --- Build segments ---

seg_cwd=""
[ -n "$rel_path" ] && seg_cwd="${SEP}${DIM}${ICON_CWD} ${rel_path}${R}"

seg_git=""
[ -n "$git_branch" ] && seg_git="${SEP}${CYAN}${ICON_GIT} ${git_branch}${R}"

seg_ctx=""
if [ -n "$ctx_window_size" ]; then
  ctx_pct_int=$(printf "%.0f" "$ctx_used_pct" 2>/dev/null || echo "$ctx_used_pct")
  seg_ctx="${SEP}${MAGENTA}${ICON_CTX} $(fmtk "$ctx_window_size") ${ctx_pct_int}% used${R}"
fi

seg_tokens=""
[ -n "$total_in" ] && [ -n "$total_out" ] && \
  seg_tokens="\n${BLUE}${ICON_TOKEN}(i/o) Σ $(fmtk "$total_in")/$(fmtk "$total_out")${R}"

seg_cur=""
[ -n "$current_in" ] && [ -n "$current_out" ] && \
  seg_cur=" ${BLUE}▸ $(fmtk "$current_in")/$(fmtk "$current_out")${R}"

seg_cache=""
cr=""; cw=""
[ -n "$cache_read" ] && [ "$cache_read" -gt 0 ] 2>/dev/null && cr="$(fmtk "$cache_read") hit"
[ -n "$cache_write" ] && [ "$cache_write" -gt 0 ] 2>/dev/null && cw="$(fmtk "$cache_write") write"
cache_parts="${cr:+$cr}${cr:+${cw:+/}}${cw:+$cw}"
[ -n "$cache_parts" ] && seg_cache="${DIM} | ${ICON_CACHE} ${cache_parts}${R}"

printf "%b%b%b%b%b%b%b%b%b" \
  "${YELLOW}${ICON_PROJ} ${proj_name}${R}" "$seg_cwd" "$SEP" "${GREEN}${model}${R}" \
  "$seg_git" "$seg_ctx" "$seg_tokens" "$seg_cur" "$seg_cache"
