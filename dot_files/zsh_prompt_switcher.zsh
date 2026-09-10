# Prompt switcher: switch between starship and p10k variants in a live shell
# Usage: load_starship, load_p10k_lean, load_p10k_classic, load_p10k_rainbow, load_p10k_terse

_P10K_DIR="$HOME/.config/powerlevel10k"
_P10K_CONFIGS="$HOME/configs/dot_files/p10k_configs"

_load_p10k() {
  local variant="$1"
  local config="$_P10K_CONFIGS/dot_p10k_${variant}.zsh"
  if [[ ! -f "$config" ]]; then
    echo "Config not found: $config"
    return 1
  fi
  # Clear starship hooks if active
  precmd_functions=(${precmd_functions:#starship_*})
  preexec_functions=(${preexec_functions:#starship_*})
  PROMPT='' RPROMPT=''
  # Load p10k
  source "$_P10K_DIR/powerlevel10k.zsh-theme"
  source "$config"
  export MY_PROMPT=powerlevel10k p10k_variant="$variant"
}

load_p10k_lean()    { _load_p10k lean; }
load_p10k_classic() { _load_p10k classic; }
load_p10k_rainbow() { _load_p10k rainbow; }
load_p10k_terse()   { _load_p10k terse; }

load_starship() {
  # Clear p10k hooks if active
  unset -m 'POWERLEVEL9K_*'
  precmd_functions=(${precmd_functions:#_p9k_*})
  precmd_functions=(${precmd_functions:#gitstatus_*})
  preexec_functions=(${preexec_functions:#_p9k_*})
  PROMPT='' RPROMPT=''
  eval "$(starship init zsh)"
  export MY_PROMPT=starship
}
