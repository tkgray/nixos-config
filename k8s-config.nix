# k8s-config.nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core K8s tools
    kubectl
    kubernetes-helm
    
    # Management tools you actually want
    k9s          # Terminal UI (pros love this)
    kustomize    # K8s config management
    krew         # Plugin manager
    
    # Optional but recommended
    kubectx      # Quick context switching
  ];

  # Kubectl completion
  programs.bash.completion.enable = true;
  programs.bash.interactiveShellInit = ''
    source ${pkgs.kubectl}/share/bash-completion/completions/kubectl
  '';
  
  # Fish shell users
  programs.fish.interactiveShellInit = ''
    ${pkgs.kubectl}/share/fish/vendor_completions.d/kubectl.fish
  '';

  systemd.tmpfiles.settings.kubectl_config = {
    # Create .kube directory if it doesn't exist
    "/home/${config.users.users.tom.name}/.kube".d = {
      user = "tom";
      group = "users";
      mode = "0700";
    };
  };
}
