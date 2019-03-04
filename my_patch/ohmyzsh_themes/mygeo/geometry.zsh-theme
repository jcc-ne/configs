# Geometry
# Based on Avit and Pure
# avit: https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/avit.zsh-theme
# pure: https://github.com/sindresorhus/pure
GEOMETRY_ROOT=${0:A:h}
source "$GEOMETRY_ROOT/lib/async.zsh"
source "$GEOMETRY_ROOT/lib/plugin.zsh"
source "$GEOMETRY_ROOT/lib/time.zsh"
source "$GEOMETRY_ROOT/lib/color.zsh"
source "$GEOMETRY_ROOT/lib/grep.zsh"

# Color definitions
GEOMETRY_COLOR_EXIT_VALUE=${GEOMETRY_COLOR_EXIT_VALUE:-magenta}
# GEOMETRY_COLOR_PROMPT=${GEOMETRY_COLOR_PROMPT:-white}
GEOMETRY_COLOR_PROMPT=${GEOMETRY_COLOR_PROMPT:-blue}
GEOMETRY_COLOR_ROOT=${GEOMETRY_COLOR_ROOT:-red}
GEOMETRY_COLOR_DIR=${GEOMETRY_COLOR_DIR:-blue}

if [[ $TERM = *256color* || $TERM = *rxvt* ]]; then
    turquoise="%F{81}"
    orange="$FG[166]"
    cloudBlue="$FG[033]"
    purple="$FG[135]"
    hotpink="%F{161}"
    limegreen="%F{118}"
    darkerBlue="$FG[111]"
    purpleBlue="%F{63}"
    darkYellow="$FG[214]"
	gray="$FG[245]"
else
    turquoise="$fg[cyan]"
    orange="$fg[yellow]"
    purple="$fg[magenta]"
    cloudBlue="$fg[magnenta]"
    hotpink="$fg[red]"
    limegreen="$fg[green]"
    darkerBlue="$fg[blue]"
    purpleBlue="$fg[blue]"
    darkYellow="$fg[yellow]"
	gray="$fg[8]"
fi

# Symbol definitions
# GEOMETRY_SYMBOL_PROMPT=${GEOMETRY_SYMBOL_PROMPT-"▲"}
GEOMETRY_SYMBOL_PROMPT=${GEOMETRY_SYMBOL_PROMPT-"☀"}

GEOMETRY_SYMBOL_RPROMPT=${GEOMETRY_SYMBOL_RPROMPT-"◇"}
# GEOMETRY_SYMBOL_EXIT_VALUE=${GEOMETRY_SYMBOL_EXIT_VALUE-"△"}
GEOMETRY_SYMBOL_EXIT_VALUE=${GEOMETRY_SYMBOL_EXIT_VALUE-"☂"}
GEOMETRY_SYMBOL_ROOT=${GEOMETRY_SYMBOL_ROOT-"▲"}

# Combine color and symbols
GEOMETRY_EXIT_VALUE=$(prompt_geometry_colorize $GEOMETRY_COLOR_EXIT_VALUE $GEOMETRY_SYMBOL_EXIT_VALUE)
GEOMETRY_PROMPT=$(prompt_geometry_colorize $GEOMETRY_COLOR_PROMPT $GEOMETRY_SYMBOL_PROMPT)

# Flags
PROMPT_GEOMETRY_COLORIZE_SYMBOL=${PROMPT_GEOMETRY_COLORIZE_SYMBOL:-false}
PROMPT_GEOMETRY_COLORIZE_ROOT=${PROMPT_GEOMETRY_COLORIZE_ROOT:-false}
PROMPT_GEOMETRY_SHOW_RPROMPT=${PROMPT_GEOMETRY_SHOW_RPROMPT:-true}
PROMPT_GEOMETRY_RPROMPT_ASYNC=${PROMPT_GEOMETRY_RPROMPT_ASYNC:-true}
PROMPT_GEOMETRY_ENABLE_PLUGINS=${PROMPT_GEOMETRY_ENABLE_PLUGINS:-true}

# Misc configurations
# GEOMETRY_PROMPT_PREFIX=${GEOMETRY_PROMPT_PREFIX-$'\n'}
GEOMETRY_PROMPT_PREFIX=${GEOMETRY_PROMPT_PREFIX-""}
# GEOMETRY_PROMPT_SUFFIX=${GEOMETRY_PROMPT_SUFFIX-""}
GEOMETRY_PROMPT_SUFFIX=${GEOMETRY_PROMPT_SUFFIX-"%{$reset_color%}"}
GEOMETRY_PROMPT_PREFIX_SPACER=${GEOMETRY_PROMPT_PREFIX_SPACER-" "}
GEOMETRY_SYMBOL_SPACER=${GEOMETRY_SYMBOL_SPACER-" "}
# GEOMETRY_DIR_SPACER=${GEOMETRY_DIR_SPACER-" "}
GEOMETRY_DIR_SPACER=${GEOMETRY_DIR_SPACER-" ☁"}

# Show current command in title
prompt_geometry_set_cmd_title() {
  local COMMAND="${2}"
  local CURR_DIR="${PWD##*/}"
  setopt localoptions no_prompt_subst
  print -n '\e]0;'
  print -rn "$COMMAND @ $CURR_DIR"
  print -n '\a'
}

# Prevent command showing on title after ending
prompt_geometry_set_title() {
  print -n '\e]0;'
  print -Pn '%~'
  print -n '\a'
}

prompt_geometry_render_rprompt() {
    # Renders all registered plugins
    geometry_plugin_render
}
time="%(?.%{$darkerBlue%}.%{$fg[red]%})%*%{$reset_color%}"

prompt_geometry_render_lprompt() {
   LINE='%{$gray%}%-------------------------------------------------------------%{$reset_color%}'
  echo "$LINE"
  echo '$GEOMETRY_PROMPT_PREFIX$GEOMETRY_PROMPT_PREFIX_SPACER%${#PROMPT_SYMBOL}{%(?.$GEOMETRY_PROMPT.$GEOMETRY_EXIT_VALUE)%}$GEOMETRY_SYMBOL_SPACER%F{$GEOMETRY_COLOR_DIR}%4~%f%{$cloudBlue%}$GEOMETRY_DIR_SPACER ${time}$GEOMETRY_PROMPT_SUFFIX%{$reset_color%}'
  echo '%{$orange%} ♛ %{$reset_color%}'
}

prompt_geometry_render() {
  if [ $? -eq 0 ] ; then
    PROMPT_SYMBOL=$GEOMETRY_SYMBOL_PROMPT
  else
    PROMPT_SYMBOL=$GEOMETRY_SYMBOL_EXIT_VALUE
  fi

  PROMPT="$(prompt_geometry_render_lprompt)"

  PROMPT2=" $GEOMETRY_SYMBOL_RPROMPT "

  if $PROMPT_GEOMETRY_SHOW_RPROMPT; then
    if $PROMPT_GEOMETRY_RPROMPT_ASYNC; then
        # On render we reset rprompt until async process
        # comes with newer git info
        RPROMPT=""
    else
        setopt localoptions no_prompt_subst
        RPROMPT="$(prompt_geometry_render_rprompt)"
    fi
  fi
}

prompt_geometry_setup() {
  zmodload zsh/datetime
  autoload -U add-zsh-hook
  if $PROMPT_GEOMETRY_ENABLE_PLUGINS; then
      geometry_plugin_setup
  fi

  if $PROMPT_GEOMETRY_COLORIZE_SYMBOL; then
    export GEOMETRY_COLOR_PROMPT=$(prompt_geometry_hash_color $HOST)
    export GEOMETRY_PROMPT=$(prompt_geometry_colorize $GEOMETRY_COLOR_PROMPT $GEOMETRY_SYMBOL_PROMPT)
  fi

  # TODO make plugin root.zsh
  if $PROMPT_GEOMETRY_COLORIZE_ROOT && [[ $UID == 0 || $EUID == 0 ]]; then
    export GEOMETRY_PROMPT=$(prompt_geometry_colorize $GEOMETRY_COLOR_ROOT $GEOMETRY_SYMBOL_ROOT)
  fi

  add-zsh-hook preexec prompt_geometry_set_cmd_title
  add-zsh-hook precmd prompt_geometry_set_title
  add-zsh-hook precmd prompt_geometry_render

  if $PROMPT_GEOMETRY_SHOW_RPROMPT && $PROMPT_GEOMETRY_RPROMPT_ASYNC; then
     geometry_async_setup
  fi
}

prompt_geometry_setup
