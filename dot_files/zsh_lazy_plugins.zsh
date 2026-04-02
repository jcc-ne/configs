# Lazy-load heavy tool completions on first use (standalone, no oh-my-zsh)

kubectl() {
  unfunction kubectl
  source <(command kubectl completion zsh)
  kubectl "$@"
}

helm() {
  unfunction helm
  source <(command helm completion zsh)
  helm "$@"
}

docker() {
  unfunction docker
  if [[ -f /opt/homebrew/share/zsh/site-functions/_docker ]]; then
    fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
    autoload -Uz compinit && compinit -C
  fi
  docker "$@"
}

gcloud() {
  unfunction gcloud
  if [[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]]; then
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
  fi
  gcloud "$@"
}
