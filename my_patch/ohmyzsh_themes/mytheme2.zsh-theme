# On a mac with snow leopard, for nicer terminal colours:

# - Install SIMBL: http://www.culater.net/software/SIMBL/SIMBL.php
# - Download'Terminal-Colours': http://bwaht.net/code/TerminalColours.bundle.zip
# - Place that bundle in ~/Library/Application\ Support/SIMBL/Plugins (create that folder if it doesn't exist)
# - Open Terminal preferences. Go to Settings -> Text -> More
# - Change default colours to your liking.
#
# Here are the colours from Textmate's Monokai theme:
#
# Black: 0, 0, 0
# Red: 229, 34, 34
# Green: 166, 227, 45
# Yellow: 252, 149, 30
# Blue: 196, 141, 255
# Magenta: 250, 37, 115
# Cyan: 103, 217, 240
# White: 242, 242, 242
#use extended color pallete if available
if [[ $TERM = *256color* || $TERM = *rxvt* ]]; then
    turquoise="%F{81}"
    orange="$FG[166]"
    cloudBlue="$FG[033]"
    purple="$FG[135]"
    hotpink="%F{161}"
    limegreen="%F{118}"
    darkerBlue="%F{111}"
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

# Thanks to Steve Losh: http://stevelosh.com/blog/2009/03/candy-colored-terminal/
# local time, color coded by last return code
time_enabled="%(?.%{$darkerBlue%}.%{$fg[red]%})%*%{$reset_color%}"
time_disabled="%{$fg[green]%}%*%{$reset_color%}"
time=$time_enabled

# The prompt
# %m hostname
    VIM_PROMPT="%{$fg_bold[yellow]%} [% N]% %{$reset_color%}"
    PSVIM="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"

PROMPT='%{$gray%}%-------------------------------------------------------------%{$reset_color%}
%{$purple%} %m ★ %{$reset_color%}${time}%{$fg[yellow]%} ☀ %{$purpleBlue%}%4~%{$reset_color%}  %{$fg[gray]%}〈$(git_prompt_info)%{$reset_color%}$(git_prompt_status)%{$reset_color%} %{$fg[gray]%}〉
%{$cloudBlue%} ☁ %{$reset_color%} '

# PROMPT='%{$fg[black]%}$(git_prompt_info)%{$reset_color%}%{$darkYellow%}$(git_commit_id)%{$reset_color%}$(git_prompt_status)%{$reset_color%}%{$cloudBlue%} ☁ %{$reset_color%}'
# PROMPT=$'
# %{$purple%}%n%{$reset_color%} in %{$limegreen%}%~%{$reset_color%}$(rvm-prompt " with%{$fg[red]%} " v g "%{$reset_color%}")$vcs_info_msg_0_%{$orange%} λ%{$reset_color%} '
#

# The right-hand prompt
git_commit_id() {
  git rev-parse --short HEAD 2>/dev/null
}

# RPROMPT='%{$fg[black]%}$(git_prompt_info)%{$reset_color%}%{$darkYellow%}$(git_commit_id)%{$reset_color%}$(git_prompt_status)%{$reset_color%}%{$cloudBlue%} ☁ %{$reset_color%}'
# $(git_prompt_ahead)
# Add this at the start of RPROMPT to include rvm info showing ruby-version@gemset-name
# %{$fg[yellow]%}$(~/.rvm/bin/rvm-prompt)%{$reset_color%}


# ZSH_THEME_GIT_PROMPT_PREFIX="%{$cloudBlue%}☁ " #☁ %{$fg[red]%}
ZSH_THEME_GIT_PROMPT_PREFIX="%{$cloudBlue%}" #☁ %{$fg[red]%}
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
# ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[yellow]%} ☂ " # Ⓓ
ZSH_THEME_GIT_PROMPT_DIRTY="" # Ⓓ
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[green]%} ✔" # Ⓞ

ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$orange%}☂ " # ☀ⓣ
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[cyan]%}✚" # ⓐ ⑃
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[yellow]%}⚡"  # ⓜ ⑁
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}✖" # ⓧ ⑂
ZSH_THEME_GIT_PROMPT_RENAMED="%{$orange%}✐" # ⓡ ⑄➜
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[magenta]%} ♒" # ⓤ ⑊
ZSH_THEME_GIT_PROMPT_AHEAD="%{$purple%}⚑"

# :dig to list symbols
# More symbols to choose from:
# ☀ ✹ ☄ ♆ ♀ ♁ ♐ ♇ ♈ ♉ ♚ ♛ ♜ ♝ ♞ ♟ ♠ ♣ ⚢ ⚲ ⚳ ⚴ ⚥ ⚤ ⚦ ⚒ ⚑ ⚐ ♺ ♻ ♼ ☰ ☱ ☲ ☳ ☴ ☵ ☶ ☷
# ✡ ✔ ✖ ✚ ✱ ✤ ✦ ❤ ➜ ➟ ➼ ✂ ✎ ✐ ⨀ ⨁ ⨂ ⨍ ⨎ ⨏ ⨷ ⩚ ⩛ ⩡ ⩱ ⩲ ⩵  ⩶ ⨠
# ⬅ ⬆ ⬇ ⬈ ⬉ ⬊ ⬋ ⬒ ⬓ ⬔ ⬕ ⬖ ⬗ ⬘ ⬙ ⬟  ⬤ 〒 ǀ ǁ ǂ ĭ Ť Ŧ

# Determine if we are using a gemset.
function rvm_gemset() {
    GEMSET=`rvm gemset list | grep '=>' | cut -b4-`
    if [[ -n $GEMSET ]]; then
        echo "%{$fg[yellow]%}$GEMSET%{$reset_color%}|"
    fi
}

# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function git_time_since_commit() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Only proceed if there is actually a commit.
        if [[ $(git log 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
            # Get the last commit.
            last_commit=`git log --pretty=format:'%at' -1 2> /dev/null`
            now=`date +%s`
            seconds_since_last_commit=$((now-last_commit))

            # Totals
            MINUTES=$((seconds_since_last_commit / 60))
            HOURS=$((seconds_since_last_commit/3600))

            # Sub-hours and sub-minutes
            DAYS=$((seconds_since_last_commit / 86400))
            SUB_HOURS=$((HOURS % 24))
            SUB_MINUTES=$((MINUTES % 60))

            if [[ -n $(git status -s 2> /dev/null) ]]; then
                if [ "$MINUTES" -gt 30 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG"
                elif [ "$MINUTES" -gt 10 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM"
                else
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT"
                fi
            else
                COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            fi

            if [ "$HOURS" -gt 24 ]; then
                echo "($(rvm_gemset)$COLOR${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m%{$reset_color%}|"
            elif [ "$MINUTES" -gt 60 ]; then
                echo "($(rvm_gemset)$COLOR${HOURS}h${SUB_MINUTES}m%{$reset_color%}|"
            else
                echo "($(rvm_gemset)$COLOR${MINUTES}m%{$reset_color%}|"
            fi
        else
            COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            echo "($(rvm_gemset)$COLOR~|"
        fi
    fi
}
