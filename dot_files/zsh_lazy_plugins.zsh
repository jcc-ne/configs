# Lazy-load heavy oh-my-zsh plugins on first use
kubectl() {
  unfunction kubectl
  source $ZSH/plugins/kubectl/kubectl.plugin.zsh
  kubectl "$@"
}

helm() {
  unfunction helm
  source $ZSH/plugins/helm/helm.plugin.zsh
  helm "$@"
}

docker() {
  unfunction docker
  source $ZSH/plugins/docker/docker.plugin.zsh
  docker "$@"
}

gcloud() {
  unfunction gcloud
  source $ZSH/plugins/gcloud/gcloud.plugin.zsh
  gcloud "$@"
}
