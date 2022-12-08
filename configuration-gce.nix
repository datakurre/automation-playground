{ config, pkgs, lib, ... }: {

  config = {
    options.username = "user";
    options.ssl = true;
    options.shared-folder = false;

    users.extraUsers = builtins.listToAttrs [{
      name = config.options.username;
      value = {
        isNormalUser    = true;
        createHome      = true;
        description     = "User account";
        extraGroups     = [ "${config.options.username}" "wheel" ];
        home            = "/home/${config.options.username}";
        password        = "${config.options.username}";
        useDefaultShell = true;
        uid             = 1000;
      };
    }];

    security.sudo.wheelNeedsPassword = false;

    services.xserver.enable = true;
    services.xserver.videoDrivers = [];

    services.xserver.displayManager.job.execCmd = let lightdm = pkgs.lightdm.overrideDerivation(old: rec {
      pname = "lightdm";
      version = "1.30.0";
      src = pkgs.fetchFromGitHub {
        owner = "CanonicalLtd";
        repo = pname;
        rev = version;
        sha256 = "0i1yygmjbkdjnqdl9jn8zsa1mfs2l19qc4k2capd8q1ndhnjm2dx";
      };
    }); in pkgs.lib.mkForce ''
      export PATH=${lightdm}/sbin:$PATH
      exec ${lightdm}/sbin/lightdm
    '';

    # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/x11/display-managers/lightdm.nix
    environment.etc."lightdm/lightdm.conf".source = with lib; let
      xcfg = config.services.xserver;
      dmcfg = xcfg.displayManager;
      xEnv = config.systemd.services.display-manager.environment;
      cfg = dmcfg.lightdm;
      sessionData = dmcfg.sessionData;
      xserverWrapper = pkgs.writeScript "xserver-wrapper" ''
        #! ${pkgs.bash}/bin/bash
        ${concatMapStrings (n: "export ${n}=\"${getAttr n xEnv}\"\n") (attrNames xEnv)}
        echo "FOO" > /tmp/foo
        exec ${pkgs.xorg.xorgserver}/bin/Xvfb -screen 0 1920x1080x24 :0 -seat seat0 -auth /var/run/lightdm/root/:0 -nolisten tcp
    '';
    in mkForce (pkgs.writeText "lightdm.conf" ''
      [LightDM]
      ${optionalString cfg.greeter.enable ''
        greeter-user = ${config.users.users.lightdm.name}
        greeters-directory = ${cfg.greeter.package}
      ''}
      sessions-directory = ${dmcfg.sessionData.desktops}/share/xsessions:${dmcfg.sessionData.desktops}/share/wayland-sessions
      ${cfg.extraConfig}
      [Seat:*]
      xserver-command = ${xserverWrapper}
      session-wrapper = ${dmcfg.sessionData.wrapper}
      ${optionalString cfg.greeter.enable ''
        greeter-session = ${cfg.greeter.name}
      ''}
      ${optionalString dmcfg.autoLogin.enable ''
        autologin-user = ${dmcfg.autoLogin.user}
        autologin-user-timeout = ${toString cfg.autoLogin.timeout}
        autologin-session = ${sessionData.autologinSession}
      ''}
      ${optionalString (dmcfg.setupCommands != "") ''
        display-setup-script=${pkgs.writeScript "lightdm-display-setup" ''
          #!${pkgs.bash}/bin/bash
          ${dmcfg.setupCommands}
        ''}
      ''}
    '');
  };
}
