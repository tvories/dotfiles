{ pkgs, config, ... }:
let ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  sops.secrets.taylor-password = {
    sopsFile = ./secret.sops.yaml;
    neededForUsers = true;
  };
  users.mutableUsers = false;
  users.users.taylor = {
    isNormalUser = true;
    shell = pkgs.fish;
    passwordFile = config.sops.secrets.taylor-password.path;
    extraGroups = [
      "wheel"
    ] ++ ifTheyExist [
      "network"
      "samba-users"
    ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHthY1nXKAUHoco25JcN5qZ2sNs34gKCmXH4jslR5/tN 1pw-taylor"
    ];

    packages = [ pkgs.home-manager ];
  };

  home-manager.users.taylor = import ../../../../../home-manager/taylor_${config.networking.hostName}.nix;
}
