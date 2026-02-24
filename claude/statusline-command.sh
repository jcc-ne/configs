#!/bin/sh
# Claude Code status line script - Powerline Style

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

# Powerline separators (U+E0B0, U+E0B1 as raw UTF-8 bytes)
SEP_RIGHT=$(printf '\xee\x82\xb0')  #
SEP_THIN=$(printf '\xee\x82\xb1')   #

# ANSI color codes - Vim Airline Powerline Style
R="\033[0m"
# Foreground colors for text
FG_BLACK="\033[38;5;232m"        # Near black (for text on lime green segment)
FG_WHITE="\033[38;5;252m"        # Light gray (for text on dark segments)
FG_BRIGHT_WHITE="\033[38;5;252m" # Light gray (for text on dark segments)
FG_RED="\033[38;5;160m"          # Red (for context percentage value)
# Background colors for powerline segments
BG_BLUE="\033[48;5;148m"      # Segment 1 (Project): Lime green bg
BG_GREEN="\033[48;5;237m"     # Segment 4 (Model): Dark gray bg
BG_YELLOW="\033[48;5;136m"    # Not used
BG_MAGENTA="\033[48;5;234m"   # Segment 5 (Context): Dark near-black bg
BG_CYAN="\033[48;5;234m"      # Segment 3 (Git): Dark near-black bg
BG_GRAY="\033[48;5;238m"      # Segment 6 (Time): Medium-dark gray bg
BG_DARK_GRAY="\033[48;5;234m" # Segment 2 (Path): Dark near-black bg
# Foreground colors for separators
FG_BLUE="\033[38;5;148m"      # Lime green (separator after segment 1)
FG_GREEN="\033[38;5;237m"     # Separator after model segment
FG_YELLOW="\033[38;5;252m"    # Light gray (for segment 5 text)
FG_MAGENTA="\033[38;5;234m"   # Separator after context segment
FG_CYAN="\033[38;5;234m"      # Dark near-black (separator after segment 3)
FG_GRAY="\033[38;5;238m"      # Separator after time segment (final)
FG_DARK_GRAY="\033[38;5;234m" # Dark near-black (for segment 2 separator)

# Icons
ICON_PROJ=$(printf '\xf3\xb1\x9c\xa4')  # 󱜤
ICON_CWD=$(printf '\xf3\xb0\x9d\xb0')   # 󰝰
ICON_GIT=$(printf '\xef\x84\xa6')       #
ICON_CTX=$(printf '\xef\x80\xbe')       #
ICON_TOKEN=$(printf '\xee\xb7\xa8')     #
ICON_CACHE=$(printf '\xef\x92\x9b')     #
ICON_TIME=$(printf '\xef\x80\x97')      #

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

# Current time
current_time=$(date '+%H:%M:%S')

# --- Build Powerline segments ---
output=""

# Segment 1: Project (Lime green bg with black fg text)
output="${output}${BG_BLUE}${FG_BLACK} ${ICON_PROJ} ${proj_name} ${R}"

# Segment 2: Path (Dark bg with light gray fg text) - only if rel_path exists
if [ -n "$rel_path" ]; then
  output="${output}\033[38;5;148m${BG_DARK_GRAY}${SEP_RIGHT}${R}"
  output="${output}${BG_DARK_GRAY}${FG_WHITE} ${ICON_CWD} ${rel_path} ${R}"
  prev_bg="DARK_GRAY"
else
  prev_bg="BLUE"
fi

# Segment 3: Git Branch (Dark bg with light gray fg text) - only if git_branch exists
if [ -n "$git_branch" ]; then
  if [ "$prev_bg" = "DARK_GRAY" ]; then
    output="${output}\033[38;5;234m${BG_CYAN}${SEP_RIGHT}${R}"
  else
    output="${output}\033[38;5;148m${BG_CYAN}${SEP_RIGHT}${R}"
  fi
  output="${output}${BG_CYAN}${FG_WHITE} ${ICON_GIT} ${git_branch} ${R}"
  prev_bg="CYAN"
fi

# Segment 4: Model (Dark bg with light gray fg text)
if [ "$prev_bg" = "CYAN" ]; then
  output="${output}\033[38;5;234m${BG_GREEN}${SEP_RIGHT}${R}"
elif [ "$prev_bg" = "DARK_GRAY" ]; then
  output="${output}\033[38;5;234m${BG_GREEN}${SEP_RIGHT}${R}"
else
  output="${output}\033[38;5;148m${BG_GREEN}${SEP_RIGHT}${R}"
fi
output="${output}${BG_GREEN}${FG_WHITE} ${model} ${R}"

# Segment 5: Context Window - only if ctx info exists
if [ -n "$ctx_window_size" ]; then
  ctx_pct_int=$(printf "%.0f" "$ctx_used_pct" 2>/dev/null || echo "$ctx_used_pct")
  # Separator: fg = model bg (237) since model always precedes context
  output="${output}\033[38;5;237m${BG_MAGENTA}${SEP_RIGHT}${R}"
  # Pct color: green < 50%, red > 65%, yellow in between
  if [ "$ctx_pct_int" -lt 50 ] 2>/dev/null; then
    FG_CTX_PCT="\033[38;5;34m"
  elif [ "$ctx_pct_int" -gt 65 ] 2>/dev/null; then
    FG_CTX_PCT="\033[38;5;160m"
  else
    FG_CTX_PCT="\033[38;5;220m"
  fi
  output="${output}${BG_MAGENTA}${FG_WHITE} ${ICON_CTX} $(fmtk "$ctx_window_size") ${SEP_THIN} ${FG_CTX_PCT}${ctx_pct_int}%${FG_WHITE} ${R}"
  prev_bg="MAGENTA"
else
  prev_bg="GREEN"
fi

# Segment 6: Time (medium-dark gray bg)
if [ "$prev_bg" = "MAGENTA" ]; then
  output="${output}\033[38;5;234m${BG_GRAY}${SEP_RIGHT}${R}"
else
  output="${output}\033[38;5;237m${BG_GRAY}${SEP_RIGHT}${R}"
fi
output="${output}${BG_GRAY}${FG_BRIGHT_WHITE} ${ICON_TIME} ${current_time} ${R}"

# Final separator
output="${output}${FG_GRAY}${SEP_RIGHT}${R}"

# Line 2: Token stats (if available)
line2=""
if [ -n "$total_in" ] && [ -n "$total_out" ]; then
  FG_TOKEN="\033[38;5;33m"
  FG_TOKEN_DIM="\033[38;5;61m"
  line2="${FG_TOKEN}${ICON_TOKEN} $(fmtk "$total_in") ↑ / $(fmtk "$total_out") ↓${R}"

  # Current call tokens
  if [ -n "$current_in" ] && [ -n "$current_out" ]; then
    line2="${line2} ${FG_TOKEN_DIM}( + $(fmtk "$current_in") ↑ / + $(fmtk "$current_out") ↓ )${R}"
  fi

  # Cache stats
  cr=""; cw=""
  [ -n "$cache_read" ] && [ "$cache_read" -gt 0 ] 2>/dev/null && cr="$(fmtk "$cache_read") read"
  [ -n "$cache_write" ] && [ "$cache_write" -gt 0 ] 2>/dev/null && cw="$(fmtk "$cache_write") write"
  cache_parts="${cr:+$cr}${cr:+${cw:+ / }}${cw:+$cw}"
  [ -n "$cache_parts" ] && line2="${line2} ${FG_DARK_GRAY}${SEP_THIN}${R} ${FG_TOKEN_DIM}${ICON_CACHE} ${cache_parts}${R}"

  output="${output}\n${line2}"
fi

printf "%b" "$output"
