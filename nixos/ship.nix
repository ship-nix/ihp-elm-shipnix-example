# Shipnix recommended settings
# IMPORTANT: These settings are here for ship-nix to function properly on your server
# Modify with care

{ config, pkgs, modulesPath, lib, ... }:
{
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations
    '';
    settings = {
      trusted-users = [ "root" "ship" "nix-ssh" ];
    };
  };

  programs.git.enable = true;
  programs.git.config = {
    advice.detachedHead = false;
  };

  services.openssh = {
    enable = true;
    # ship-nix uses SSH keys to gain access to the server
    # Manage permitted public keys in the `authorized_keys` file
    passwordAuthentication = false;
    #  permitRootLogin = "no";
  };


  users.users.ship = {
    isNormalUser = true;
    extraGroups = [ "wheel" "nginx" ];
    # If you don't want public keys to live in the repo, you can remove the line below
    # ~/.ssh will be used instead and will not be checked into version control. 
    # Note that this requires you to manage SSH keys manually via SSH,
    # and your will need to manage authorized keys for root and ship user separately
    openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCoRQTGE/xheYTp7JsWdSumWH6wpOX4ir1fX0P+fYw+tC2rDCEK4vlLHSCejtNjabpGu3Sl7qQ+7i9/+2awGwzeAaO1qWAf2UPhcZ5lDi2u9Tkr4hGrPinHWxrFp79fB71GUEhWtgAyK42SEmEdbsmN7PWIj/0KqzP7syLJ+Zk7DSw4ZjSVTn7DCyHZgOzP4k6tcdB5doVM1IyKxDBC7IDPxhQvoGZE/ShABShAAeQIGLh8OLp213x8tx77VfWUmOrQ+oPcTbxORe00JFI/ZRoWs27iUEL1IckiVMlwzmqlhDytJZ0lKtSalTw4aRZsBvSTgZZD6FEl2nXWpBcCEfSGwDQEdZq3hbuv8ASqlOZxo4ARPTTja2kKbWSFeijrzpw9EBPdUNnIvDIpzlK/scE8+PujKAM/L8a2y+97BPjyoJuY5MnVdpvjraiaunnrxbRkjoSC+wiG9JJYQo5E4W4f4dXi+sBkTm/QkyWWs0gIrSv6ql7IWrKGHXdglwpB67U= lillo@kodeFant
"
    ];
  };

  # Can be removed if you want authorized keys to only live on server, not in repository
  # Se note above for users.users.ship.openssh.authorizedKeys.keyFiles
  users.users.root.openssh.authorizedKeys.keyFiles = [ ./authorized_keys ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCoRQTGE/xheYTp7JsWdSumWH6wpOX4ir1fX0P+fYw+tC2rDCEK4vlLHSCejtNjabpGu3Sl7qQ+7i9/+2awGwzeAaO1qWAf2UPhcZ5lDi2u9Tkr4hGrPinHWxrFp79fB71GUEhWtgAyK42SEmEdbsmN7PWIj/0KqzP7syLJ+Zk7DSw4ZjSVTn7DCyHZgOzP4k6tcdB5doVM1IyKxDBC7IDPxhQvoGZE/ShABShAAeQIGLh8OLp213x8tx77VfWUmOrQ+oPcTbxORe00JFI/ZRoWs27iUEL1IckiVMlwzmqlhDytJZ0lKtSalTw4aRZsBvSTgZZD6FEl2nXWpBcCEfSGwDQEdZq3hbuv8ASqlOZxo4ARPTTja2kKbWSFeijrzpw9EBPdUNnIvDIpzlK/scE8+PujKAM/L8a2y+97BPjyoJuY5MnVdpvjraiaunnrxbRkjoSC+wiG9JJYQo5E4W4f4dXi+sBkTm/QkyWWs0gIrSv6ql7IWrKGHXdglwpB67U= lillo@kodeFant
"
  ];

  security.sudo.extraRules = [
    {
      users = [ "ship" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" "SETENV" ];
        }
      ];
    }
  ];
}
