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

    systemd.services.vnc.script = pkgs.lib.mkForce (let
      tigervnc = pkgs.tigervnc.overrideDerivation(old: {
        buildInputs = old.buildInputs ++ [
          pkgs.xorg.libXdamage.dev
          pkgs.xorg.libXfixes.dev
          pkgs.xorg.libXrandr.dev
          pkgs.xorg.libXtst
        ];
      });
    in ''
systemctl restart display-manager
while ! /run/wrappers/bin/su - ${config.options.username} -c "${pkgs.xorg.xset}/bin/xset -q"; do sleep 1; done
sleep 5  # allow slow GCE instance to catch up
response=$(${pkgs.curl}/bin/curl --write-out '%{http_code}' --silent --output /dev/null http://metadata.google.internal/computeMetadata/v1/instance/attributes/password -H "Metadata-Flavor:Google")
password=$(${pkgs.curl}/bin/curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/password -H "Metadata-Flavor:Google")
if test "$response" != "200"; then
  /run/wrappers/bin/su - ${config.options.username} -c "exec ${tigervnc}/bin/x0vncserver -localhost -SecurityTypes none -AlwaysShared -RawKeyboard"
else
  echo $password|${tigervnc}/bin/vncpasswd -f>/var/run/.vncpasswd
  /run/wrappers/bin/su - ${config.options.username} -c "exec ${tigervnc}/bin/x0vncserver -localhost -PasswordFile /var/run/.vncpasswd -AlwaysShared -RawKeyboard"
fi
    '');
  };
}
