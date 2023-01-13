{ config, pkgs, lib, home-manager, ... }:

let

  robotframework = ps:
    ps.robotframework.overridePythonAttrs(old: rec {
      version = "6.0.1";
      src = ps.fetchPypi {
        pname = "robotframework";
        extension = "zip";
        inherit version;
        sha256 = "sha256-stmoKRLf0nquevqtZHccWPXZSMqdZOOucrFnIbXgIuo=";
      };
      doCheck = false;
    });

in {

  options = {
    options.username = lib.mkOption { default = "vagrant"; };
    options.ssl = lib.mkOption { default = false; };
    options.vault = lib.mkOption { default = true; };
    options.shared-folder = lib.mkOption { default = false; };
    options.vscode-with-vim = lib.mkOption { default = false; };
    options.vscode-unfree = lib.mkOption { default = false; };
    options.rcc-service = lib.mkOption { default = false; };
  };

  config = {

    system.stateVersion = "22.05";

    powerManagement.cpuFreqGovernor = "ondemand";

    environment.systemPackages = with pkgs; [
      (python3Full.withPackages(ps: [(robotframework ps)]))
      ammonite
      camunda-modeler
      chromium
      evince
      git
      xfce.xfce4-screenshooter
      gnome.file-roller
      gnumake
      gnumeric
      mockoon
      mockoon-cli
      parrot-rcc
      podman-compose
      rccFHSUserEnv
      unzip
      vim
      zbctl
      zip
    ];

    users.groups = builtins.listToAttrs [{
      name = config.options.username;
      value = {
        gid = 1000;
        members = [ config.options.username ];
      };
    }];

    users.extraUsers = builtins.listToAttrs [{
      name = config.options.username;
      value = {
        extraGroups = [ config.options.username "podman" ];
        isNormalUser = true;
        subUidRanges = [{ startUid = 100000; count = 65536; }];
        subGidRanges = [{ startGid = 100000; count = 65536; }];
      };
    }];

    nix.settings.substituters = [ "https://datakurre.cachix.org" "https://cache.nixos.org" ];
    nix.settings.trusted-public-keys = [ "datakurre.cachix.org-1:ayZJTy5BDd8K4PW9uc9LHV+WCsdi/fu1ETIYZMooK78=" ];
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 180d";
    };
    nix.extraOptions = ''
auto-optimise-store = false
builders-use-substitutes = true
keep-outputs = true
keep-derivations = true
min-free = ${toString (100 * 1024 * 1024)}
max-free = ${toString (1024 * 1024 * 1024)}
experimental-features = nix-command flakes
    '';

    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    fonts.fontDir.enable = true;

    networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
    networking.firewall.allowedTCPPorts = if config.options.ssl then [ 443 ] else [ 8000 ];

    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "Europe/Berlin";

    services.mailhog = {
      enable = true;
    };

    services.vault = {
      package = pkgs.vault-bin;
      enable = true;
    };

    # Fix to run vault with -dev, because this is just a development VM
    systemd.services.vault.serviceConfig.ExecStart =
      pkgs.lib.mkForce "${config.services.vault.package}/bin/vault server -dev";

    services.minio = {
      enable = true;
    };

    # Fix to run vault with -dev, because this is just a development VM
    systemd.services.minio.after = [ "minio-init.service" ];

    systemd.services.minio-init = {
      enable = true;
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "minio";
        Group = "minio";
      };
      script = ''
        mkdir -p "${builtins.head config.services.minio.dataDir}/rcc"
        mkdir -p "${builtins.head config.services.minio.dataDir}/zeebe"
      '';
    };

    services.xserver = {
      enable = true;
      layout = "fi";
      xkbOptions = "eurosign:e";
      libinput.enable = true;
      displayManager = {
        defaultSession = "xfce";
        autoLogin = {
          enable = true;
          user = config.options.username;
        };
      };
      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
        xfce.enableScreensaver = false;
      };
    };
    programs.thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
    ];

    # Use known good version of lightdm
    services.xserver.displayManager.job.execCmd = let lightdm = pkgs.lightdm.overrideDerivation(old: rec {
      name = "${pname}-${version}";
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

    # Set test secret
    systemd.services.vault.environment = {
      HOME = "/tmp";
      VAULT_DEV_ROOT_TOKEN_ID = "secret";
    };

    # PostgreSQL
    services.postgresql.enable = true;

    # Podman
    virtualisation.podman.enable = true;
    virtualisation.podman.dockerCompat = true;
    virtualisation.podman.defaultNetwork.dnsname.enable = true;

    # NoVNC
    services.nginx = {
      enable = true;
      virtualHosts.localhost = {
        root = "${pkgs.novnc}/share/webapps/novnc";
        forceSSL = config.options.ssl;
        sslCertificate = "/etc/novnc-selfsigned.crt";
        sslCertificateKey = "/etc/novnc-selfsigned.key";
        locations."/websockify" = {
          proxyWebsockets = true;
          proxyPass = "http://localhost:14000";
          extraConfig = ''
proxy_read_timeout 61s;
proxy_buffering off;
proxy_set_header Host $host;
          '';
        };
        locations."/pub" = {
           root =  "/var/www";
           extraConfig = ''
             autoindex on;
           '';
        };
        locations."/" = {
          index = "vnc.html";
        };
      } // (if config.options.ssl then {} else {
        listen = [{
          addr = "localhost";
          port = 8000;
        }];
      });
    };

    systemd.services.var-www-pub = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      before = [ "nginx.service" ];
      bindsTo = [ "nginx.service" ];
      serviceConfig = {
        Type = "oneshot";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      script = ''
mkdir -p /var/www/pub
chown ${config.options.username}:users -R /var/www/pub
      '';
    };

    systemd.services.novnc-cert = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      before = [ "nginx.service" ];
      bindsTo = [ "nginx.service" ];
      path = [ pkgs.openssl ];
      serviceConfig = {
        Type = "oneshot";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      script = ''
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
 -subj "/C=US/ST=Denial/L=Springfield/O=automation-playground/CN=www.example.com" \
 -keyout /etc/novnc-selfsigned.key -out /etc/novnc-selfsigned.crt
chown nginx:root /etc/novnc-selfsigned.key
chown nginx:root /etc/novnc-selfsigned.crt
      '';
    };

    systemd.services.vnc = let
      tigervnc = pkgs.tigervnc.overrideDerivation(old: {
        buildInputs = old.buildInputs ++ [
          pkgs.xorg.libXdamage.dev
          pkgs.xorg.libXfixes.dev
          pkgs.xorg.libXrandr.dev
          pkgs.xorg.libXtst
        ];
      });
    in {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      after = [ "display-manager.service" ];
      before = [ "websockify.service" ];
      serviceConfig = {
        Environment = "DISPLAY=:0";
        Restart = "on-failure";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      script = ''
systemctl restart display-manager
while ! /run/wrappers/bin/su - ${config.options.username} -c "${pkgs.xorg.xset}/bin/xset -q"; do sleep 1; done
sleep 5  # allow slow GCE instance to catch up
/run/wrappers/bin/su - ${config.options.username} -c "exec ${tigervnc}/bin/x0vncserver -localhost -SecurityTypes none -AlwaysShared -RawKeyboard -UseBlacklist off"
      '';
    };

    systemd.services.websockify = {
      enable = true;
      wantedBy = [ "default.target" ];
      after = [ "vnc.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.python3Packages.websockify}/bin/websockify localhost:14000 localhost:5900";
      };
    };

    systemd.services.zeebe = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.zeebe ];
      environment = {
        ZEEBE_CLOCK_CONTROLLED = "true";
      };
      serviceConfig = {
        User = config.options.username;
        Group = "users";
        Restart = "on-failure";
        StateDirectory = "zeebe";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      script = let
        hazelcast_exporter_ver = "1.2.1";
        hazelcast_exporter_jar = builtins.fetchurl {
          url = "https://github.com/camunda-community-hub/zeebe-hazelcast-exporter/releases/download/${hazelcast_exporter_ver}/zeebe-hazelcast-exporter-${hazelcast_exporter_ver}-jar-with-dependencies.jar";
          sha256 = "sha256-t84bCsPZbkGAqbNlfTx0C+GLem8FGwp8oh5zCQJj9Xs=";
        }; in ''
cd $STATE_DIRECTORY
mkdir -p config
cat << EOF > config/application.yaml
# Zeebe Standalone Broker configuration file (with embedded gateway)

# This file is based on broker.standalone.yaml.template but stripped down to contain only a limited
# set of configuration options. These are a good starting point to get to know Zeebe.
# For advanced configuration options, have a look at the templates in this folder.

# !!! Note that this configuration is not suitable for running a standalone gateway. !!!
# If you want to run a standalone gateway node, please have a look at gateway.yaml.template

# ----------------------------------------------------
# Byte sizes
# For buffers and others must be specified as strings and follow the following
# format: "10U" where U (unit) must be replaced with KB = Kilobytes, MB = Megabytes or GB = Gigabytes.
# If unit is omitted then the default unit is simply bytes.
# Example:
# sendBufferSize = "16MB" (creates a buffer of 16 Megabytes)
#
# Time units
# Timeouts, intervals, and the likes, must be specified either in the standard ISO-8601 format used
# by java.time.Duration, or as strings with the following format: "VU", where:
#   - V is a numerical value (e.g. 1, 5, 10, etc.)
#   - U is the unit, one of: ms = Millis, s = Seconds, m = Minutes, or h = Hours
#
# Paths:
# Relative paths are resolved relative to the installation directory of the broker.
# ----------------------------------------------------

zeebe:
  broker:
    exporters:
      hazelcast:
        className: io.zeebe.hazelcast.exporter.HazelcastExporter
        jarPath: ${hazelcast_exporter_jar}
    gateway:
      # Enable the embedded gateway to start on broker startup.
      # This setting can also be overridden using the environment variable ZEEBE_BROKER_GATEWAY_ENABLE.
      enable: true

      network:
        # Sets the port the embedded gateway binds to.
        # This setting can also be overridden using the environment variable ZEEBE_BROKER_GATEWAY_NETWORK_PORT.
        port: 26500

      security:
        # Enables TLS authentication between clients and the gateway
        # This setting can also be overridden using the environment variable ZEEBE_BROKER_GATEWAY_SECURITY_ENABLED.
        enabled: false

    network:
      # Controls the default host the broker should bind to. Can be overwritten on a
      # per binding basis for client, management and replication
      # This setting can also be overridden using the environment variable ZEEBE_BROKER_NETWORK_HOST.
      host: 0.0.0.0

    data:
      # Specify a directory in which data is stored.
      # This setting can also be overridden using the environment variable ZEEBE_BROKER_DATA_DIRECTORY.
      directory: data
      # The size of data log segment files.
      # This setting can also be overridden using the environment variable ZEEBE_BROKER_DATA_LOGSEGMENTSIZE.
      logSegmentSize: 128MB
      # How often we take snapshots of streams (time unit)
      # This setting can also be overridden using the environment variable ZEEBE_BROKER_DATA_SNAPSHOTPERIOD.
      snapshotPeriod: 15m

    cluster:
      # Specifies the Zeebe cluster size.
      # This can also be overridden using the environment variable ZEEBE_BROKER_CLUSTER_CLUSTERSIZE.
      clusterSize: 1
      # Controls the replication factor, which defines the count of replicas per partition.
      # This can also be overridden using the environment variable ZEEBE_BROKER_CLUSTER_REPLICATIONFACTOR.
      replicationFactor: 1
      # Controls the number of partitions, which should exist in the cluster.
      # This can also be overridden using the environment variable ZEEBE_BROKER_CLUSTER_PARTITIONSCOUNT.
      partitionsCount: 1

    threads:
      # Controls the number of non-blocking CPU threads to be used.
      # WARNING: You should never specify a value that is larger than the number of physical cores
      # available. Good practice is to leave 1-2 cores for ioThreads and the operating
      # system (it has to run somewhere). For example, when running Zeebe on a machine
      # which has 4 cores, a good value would be 2.
      # This setting can also be overridden using the environment variable ZEEBE_BROKER_THREADS_CPUTHREADCOUNT
      cpuThreadCount: 2
      # Controls the number of io threads to be used.
      # This setting can also be overridden using the environment variable ZEEBE_BROKER_THREADS_IOTHREADCOUNT
      ioThreadCount: 2
EOF
cat << EOF > config/log4j2.xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN" shutdownHook="disable">
  <Properties>
    <Property name="log.pattern">%d{yyyy-MM-dd HH:mm:ss.SSS} [%X{actor-name}] [%t] %-5level
      %logger{36} - %msg%n
    </Property>
    <Property name="log.stackdriver.serviceName">\''${env:ZEEBE_LOG_STACKDRIVER_SERVICENAME:-}
    </Property>
    <Property name="log.stackdriver.serviceVersion">\''${env:ZEEBE_LOG_STACKDRIVER_SERVICEVERSION:-}
    </Property>
  </Properties>
  <Appenders>
    <Console name="Console" target="SYSTEM_OUT">
      <PatternLayout pattern="\''${log.pattern}"/>
    </Console>
    <Console name="Stackdriver" target="SYSTEM_OUT">
      <StackdriverLayout serviceName="\''${log.stackdriver.serviceName}"
        serviceVersion="\''${log.stackdriver.serviceVersion}"/>
    </Console>
  </Appenders>
  <Loggers>
    <Logger name="io.camunda.zeebe" level="\''${env:ZEEBE_LOG_LEVEL:-info}"/>
    <Logger name="io.atomix" level="\''${env:ATOMIX_LOG_LEVEL:-info}"/>
    <Root level="info">
      <AppenderRef ref="RollingFile"/>
      <AppenderRef ref="\''${env:ZEEBE_LOG_APPENDER:-Console}"/>
    </Root>
  </Loggers>
</Configuration>
EOF
export REPO=$STATE_DIRECTORY
export ZEEBE_BROKER_DATA_DIRECTORY=$STATE_DIRECTORY/data
exec broker
      '';
    };

    systemd.services.zeebe-simple-monitor-init = {
      enable = true;
      after = [ "postgresql.service" ];
      before = [ "zeebe-simple-monitor.service" ];
      bindsTo = [ "postgresql.service" ];
      path = [ config.services.postgresql.package ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "postgres";
        Group = "postgres";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      script = ''
        set -o errexit -o pipefail -o nounset -o errtrace
        shopt -s inherit_errexit
        create_role="$(mktemp)"
        trap 'rm -f "$create_role"' ERR EXIT
        echo "CREATE ROLE zeebe_monitor WITH LOGIN PASSWORD 'zeebe_monitor' CREATEDB" > "$create_role"
        psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='zeebe_monitor'" | grep -q 1 || psql -tA --file="$create_role"
        psql -tAc "SELECT 1 FROM pg_database WHERE datname = 'zeebe_monitor'" | grep -q 1 || psql -tAc 'CREATE DATABASE "zeebe_monitor" OWNER "zeebe_monitor"'
        psql -c "CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA public" -d zeebe_monitor
      '';
    };

    systemd.services.zeebe-simple-monitor = {
      enable = true;
      after = [ "zeebe-simple-monitor-init.service" "postgresql.service" ];
      bindsTo = [ "zeebe-simple-monitor-init.service" "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.zeebe-simple-monitor ];
      environment = {
        SERVER_PORT = "8080";
        ZEEBE_ENGINE = "remote";
        ZEEBE_CLIENT_BROKER_GATEWAYADDRESS = "localhost:26500";
        ZEEBE_CLOCK_ENDPOINT = "localhost:9600/actuator/clock";
        ZEEBE_CLIENT_WORKER_HAZELCAST_CONNECTION = "localhost:5701";
        SPRING_DATASOURCE_URL = "jdbc:postgresql://localhost:5432/zeebe_monitor";
        SPRING_DATASOURCE_USERNAME = "zeebe_monitor";
        SPRING_DATASOURCE_PASSWORD = "zeebe_monitor";
        SPRING_DATASOURCE_DRIVERCLASSNAME = "org.postgresql.Driver";
        SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT = "org.hibernate.dialect.PostgreSQLDialect";
        SPRING_JPA_HIBERNATE_DLL_AUTO = "create";
      };
      serviceConfig = {
        User = config.options.username;
        Group = "users";
        Restart = "on-failure";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      script = ''
exec zeebe-simple-monitor
      '';
    };

    systemd.services.zeebe-play-init = {
      enable = true;
      after = [ "postgresql.service" ];
      before = [ "zeebe-play.service" ];
      bindsTo = [ "postgresql.service" ];
      path = [ config.services.postgresql.package ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "postgres";
        Group = "postgres";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      script = ''
        set -o errexit -o pipefail -o nounset -o errtrace
        shopt -s inherit_errexit
        create_role="$(mktemp)"
        trap 'rm -f "$create_role"' ERR EXIT
        echo "CREATE ROLE zeebe_play WITH LOGIN PASSWORD 'zeebe_play' CREATEDB" > "$create_role"
        psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='zeebe_play'" | grep -q 1 || psql -tA --file="$create_role"
        psql -tAc "SELECT 1 FROM pg_database WHERE datname = 'zeebe_play'" | grep -q 1 || psql -tAc 'CREATE DATABASE "zeebe_play" OWNER "zeebe_play"'
        psql -c "CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA public" -d zeebe_play
      '';
    };

    systemd.services.zeebe-play = {
      enable = true;
      after = [ "zeebe-play-init.service" "postgresql.service" ];
      bindsTo = [ "zeebe-play-init.service" "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.zeebe-play ];
      environment = {
        SERVER_PORT = "8081";
        ZEEBE_ENGINE = "remote";
        ZEEBE_CLIENT_BROKER_GATEWAYADDRESS = "localhost:26500";
        ZEEBE_CLOCK_ENDPOINT = "localhost:9600/actuator/clock";
        ZEEBE_CLIENT_WORKER_HAZELCAST_CONNECTION = "localhost:5701";
        SPRING_DATASOURCE_URL = "jdbc:postgresql://localhost:5432/zeebe_play";
        SPRING_DATASOURCE_USERNAME = "zeebe_play";
        SPRING_DATASOURCE_PASSWORD = "zeebe_play";
        SPRING_DATASOURCE_DRIVERCLASSNAME = "org.postgresql.Driver";
        SPRING_JPA_PROPERTIES_HIBERNATE_DIALECT = "org.hibernate.dialect.PostgreSQLDialect";
        SPRING_JPA_HIBERNATE_DLL_AUTO = "create";
      };
      serviceConfig = {
        User = config.options.username;
        Group = "users";
        Restart = "on-failure";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      script = ''
exec zeebe-play
      '';
    };

    systemd.services.parrot-rcc-init = {
      enable = true;
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        mkdir -p /var/lib/rcc /opt/robocorp
        chown -R ${config.options.username}:users /var/lib/rcc /opt/robocorp
      '';
    };

    systemd.paths.parrot-rcc-watcher = {
      enable = config.options.rcc-service;
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        PathChanged = "/var/lib/rcc";
        PathModified = "/var/lib/rcc";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
    };

    systemd.services.parrot-rcc-watcher = {
      enable = config.options.rcc-service;
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      script = ''
        systemctl reset-failed parrot-rcc-watcher.path
        systemctl reset-failed parrot-rcc-watcher.service
        systemctl reset-failed parrot-rcc.service
        systemctl restart parrot-rcc.service
      '';
    };

    systemd.services.parrot-rcc = {
      enable = config.options.rcc-service;
      after = [ "zeebe.service" ];
      bindsTo = [ "zeebe.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        findutils
        netcat
        parrot-rcc
        rccFHSUserEnv
      ];
      environment = {
        SMTP_HOST = "localhost";
        SMTP_PORT = "${toString config.services.mailhog.smtpPort}";
        VAULT_ADDR = "http://${config.services.vault.address}";
        VAULT_TOKEN = "secret";
      };
      serviceConfig = {
        User = config.options.username;
        Group = "users";
        Restart = "on-failure";
        RestartSec = 1;
        StateDirectory = "rcc";
      };
      unitConfig = {
        StartLimitIntervalSec = 0;
      };
      script = ''
        rm -f $STATE_DIRECTORY/rcc
        cd $STATE_DIRECTORY
        export HOME=/home/${config.options.username}
        exec parrot-rcc $(find . -name "*.zip") --rcc-fixed-spaces --log-level=debug
      '';
    };

    home-manager.users = builtins.listToAttrs [{
      name = config.options.username;
      value = { lib, ... }: {
        home.stateVersion = "22.05";
        home.file.".config/playground/feel-repl.sc".source = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/camunda/feel-scala/8ace3a5e484134cd679b1ce4bd787aaba4e59c5d/feel-repl.sc";
          sha256 = "3ea2b6b4fd5e04958725fcbdb7839beea7b1e62b246ebd5980451e38a384f669";
        };
        home.file.".config/playground/camunda-modeler.png".source = ./files/camunda-modeler.png;
        home.file.".config/playground/camunda-modeler.desktop".source = pkgs.writeText "camunda-modeler.desktop" ''
[Desktop Entry]
StartupWMClass=camunda-modeler
Version=1.0
Name=Modeler
Exec=camunda-modeler
StartupNotify=true
Terminal=false
Icon=/home/${config.options.username}/.config/playground/camunda-modeler.png
Type=Application
MimeType=application/bpmn+xml;application/dmn+xml
        '';
        home.file.".config/playground/zeebe.png".source = ./files/zeebe.png;
        home.file.".config/playground/zeebe-monitor.desktop".source = pkgs.writeText "zeebe-monitor.desktop" ''
[Desktop Entry]
Version=1.0
Type=Link
Name=Monitor
Icon=/home/${config.options.username}/.config/playground/zeebe.png
URL=http://localhost:8080/
        '';
        home.file.".config/playground/zeebe-play.desktop".source = pkgs.writeText "zeebe-play.desktop" ''
[Desktop Entry]
Version=1.0
Type=Link
Name=Play
Icon=/home/${config.options.username}/.config/playground/zeebe.png
URL=http://localhost:8081/
        '';
        home.file.".config/playground/chromium-browser.desktop".source = pkgs.writeText "chromium-browser.desktop" ''
[Desktop Entry]
StartupWMClass=chromium-browser
Version=1.0
Name=Chromium
Exec=chromium %U
StartupNotify=true
Terminal=false
Icon=chromium
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/plain;text/html;text/xml;x-scheme-handler/ftp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/webcal;x-scheme-handler/mailto;x-scheme-handler/about;x-scheme-handler/unknown
        '';
        home.file.".config/playground/rcc.desktop".source = pkgs.writeText "rcc.desktop" (if config.options.rcc-service then ''
[Desktop Entry]
Version=1.0
Type=Application
Name=RCC
Comment=
Exec=journalctl -f -u parrot-rcc -o cat
Icon=utilities-terminal
Path=
Terminal=true
StartupNotify=false
        '' else ''
[Desktop Entry]
Version=1.0
Type=Application
Name=RCC
Comment=
Exec=env SMTP_HOST=localhost SMTP_PORT=${toString config.services.mailhog.smtpPort} VAULT_ADDR=http://${config.services.vault.address} VAULT_TOKEN=secret bash -c "parrot-rcc $(find . -name '*.zip') --rcc-fixed-spaces --log-level=debug"
Icon=utilities-terminal
Path=/var/lib/rcc
Terminal=true
StartupNotify=false
        '');
        home.file.".config/playground/keyboard.desktop".source = pkgs.writeText "keyboard.desktop" ''
[Desktop Entry]
StartupWMClass=xfce4-keyboard-settings
Version=1.0
Name=Keyboard
Exec=/run/current-system/sw/bin/xfce4-keyboard-settings
StartupNotify=false
Terminal=false
Icon=input-keyboard
Type=Application
        '';
        home.file.".config/playground/mailhog.png".source = ./files/mailhog.png;
        home.file.".config/playground/mailhog.desktop".source = pkgs.writeText "mailhog.desktop" ''
[Desktop Entry]
Version=1.0
Type=Link
Name=MailHog
Icon=/home/${config.options.username}/.config/playground/mailhog.png
URL=http://localhost:8025/
        '';
        home.file.".config/playground/mockoon.png".source = ./files/mockoon.png;
        home.file.".config/playground/mockoon.desktop".source = pkgs.writeText "mockoon.desktop" ''
[Desktop Entry]
StartupWMClass=mockoon
Version=1.0
Name=Mockoon
Exec=mockoon-1.20.0
StartupNotify=true
Terminal=false
Icon=/home/${config.options.username}/.config/playground/mockoon.png
Type=Application
        '';
        home.file.".config/playground/robocorp-code.png".source = ./files/robocorp-code.png;
        home.file.".config/playground/robocorp-code.desktop".source = pkgs.writeText "robocorp-code.desktop" ''
[Desktop Entry]
Categories=Utility;TextEditor;Development;IDE;
Comment=Code Editing. Redefined.
Exec=${if config.options.vscode-unfree then "code" else "codium"} /var/lib/rcc
GenericName=Text Editor
Icon=/home/${config.options.username}/.config/playground/robocorp-code.png
MimeType=text/plain;inode/directory;
Name=Code
StartupNotify=true
Terminal=false
Type=Application
StartupWMClass=Code
Actions=new-empty-window;
Keywords=${if config.options.vscode-unfree then "vscode" else "vscodium"};
        '';
        home.file.".config/playground/vault.png".source = ./files/vault.png;
        home.file.".config/playground/vault.desktop".source = pkgs.writeText "vault.desktop" ''
[Desktop Entry]
Version=1.0
Type=Link
Name=Vault
Icon=/home/${config.options.username}/.config/playground/vault.png
URL=http://localhost:8200/
        '';
        home.file.".config/playground/minio.png".source = ./files/minio.png;
        home.file.".config/playground/minio.desktop".source = pkgs.writeText "minio.desktop" ''
[Desktop Entry]
Version=1.0
Type=Link
Name=MinIO
Icon=/home/${config.options.username}/.config/playground/minio.png
URL=http://localhost:9000/
        '';
        home.file.".config/playground/dmn-simulator.desktop".source = pkgs.writeText "dmn-simulator.desktop" ''
[Desktop Entry]
Version=1.0
Type=Link
Name=DMN
Comment=
Icon=web-browser
URL=https://consulting.camunda.com/dmn-simulator/
        '';
        home.file.".config/playground/feel.desktop".source = pkgs.writeText "feel.desktop" ''
[Desktop Entry]
Version=1.0
Type=Application
Name=FEEL
Comment=
Exec=amm --predef /home/${config.options.username}/.config/playground/feel-repl.sc
Icon=utilities-terminal
Path=
Terminal=true
StartupNotify=false
        '';
        home.file.".config/playground/docs.desktop".source = pkgs.writeText "docs.desktop" ''
[Desktop Entry]
Version=1.0
Type=Link
Name=Docs
Comment=
Icon=emblem-documents
URL=https://datakurre.github.io/automation-playground/
        '';
        home.file.".config/playground/xfce4-session-logout.desktop".source = pkgs.writeText "xfce4-session-logout.desktop" ''
[Desktop Entry]
Version=1.0
Type=Application
Exec=xfce4-session-logout
Icon=system-log-out
StartupNotify=false
Terminal=false
Categories=System;X-XFCE;X-Xfce-Toplevel;
OnlyShowIn=XFCE;
Name=Log Out
Name[fi]=Kirjaudu ulos
        '';
        home.file.".config/playground/robot-framework.png".source = ./files/robot-framework.png;
        xsession = {
          enable = true;
          windowManager.command = ''test -n "$1" && eval "$@"'';
          initExtra= ''
# resolve desktop directory
if [ -f $HOME/.config/user-dirs.dirs ]; then
  source $HOME/.config/user-dirs.dirs
fi
if [ -z "$XDG_DESKTOP_DIR" ]; then
  XDG_DESKTOP_DIR="Desktop"
fi

# configure desktop icons
mkdir -p $XDG_DESKTOP_DIR
${if config.options.vault then "" else "rm -f $HOME/.config/playground/vault.desktop"}
cp -L $HOME/.config/playground/*.desktop $XDG_DESKTOP_DIR
chmod 0744 $XDG_DESKTOP_DIR/*.desktop
ln -s /var/www/pub $XDG_DESKTOP_DIR/Public

rm -f $XDG_DESKTOP_DIR/Shared
${if config.options.shared-folder then "ln -s /${config.options.username} $XDG_DESKTOP_DIR/Shared" else ""}
ln -s /var/lib/rcc $XDG_DESKTOP_DIR/Robots

# configure desktop background
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -t string -s $HOME/.config/playground/robot-framework.png
if [ $? -ne 0 ]; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -t string -s $HOME/.config/playground/robot-framework.png --create
fi
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/color-style -t int -s 0
if [ $? -ne 0 ]; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/color-style -t int -s 0 --create
fi
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/image-style -t int -s 1
if [ $? -ne 0 ]; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/image-style -t int -s 1 --create
fi
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/rgba1 -t double -t double -t double -t double -s 0.368627 -s 0.360784 -s 0.392157 -s 1.0
if [ $? -ne 0 ]; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/rgba1 -t double -t double -t double -t double -s 0.368627 -s 0.360784 -s 0.392157 -s 1.0 --create
fi
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorscreen/workspace0/last-image -t string -s $HOME/.config/playground/robot-framework.png
if [ $? -ne 0 ]; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorscreen/workspace0/last-image -t string -s $HOME/.config/playground/robot-framework.png --create
fi
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorscreen/workspace0/color-style -t int -s 0
if [ $? -ne 0 ]; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorscreen/workspace0/color-style -t int -s 0 --create
fi
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorscreen/workspace0/image-style -t int -s 1
if [ $? -ne 0 ]; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorscreen/workspace0/image-style -t int -s 1 --create
fi
xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorscreen/workspace0/rgba1 -t double -t double -t double -t double -s 0.368627 -s 0.360784 -s 0.392157 -s 1.0
if [ $? -ne 0 ]; then
  xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorscreen/workspace0/rgba1 -t double -t double -t double -t double -s 0.368627 -s 0.360784 -s 0.392157 -s 1.0 --create
fi

# Cleanup of weirdly appearing symlinks
rm -f /var/www/pub/pub /var/lib/rcc/rcc

# configure desktop user experience
xfconf-query -c xsettings -p /Net/IconThemeName -t string -s gnome --create
xfconf-query -c xfwm4 -p /general/workspace_count -t int -s 1 --create
setxkbmap -layout us
xfce4-panel &
          '';
        };
        home.activation = {
          xfce4Configuration = lib.hm.dag.entryAfter ["writeBoundary"] ''
# Disable RCC telemetry by default
if [ ! -d "$HOME/.robocorp" ]; then
  rcc configuration identity -t
fi

# Default applications
if [ ! -f "$HOME/.config/xfce4/helpers.rc" ]; then
  mkdir -p $HOME/.config/xfce4
  cat << EOF > $HOME/.config/xfce4/helpers.rc
WebBrowser=chromium
EOF
fi

# VSCode defaults
if [ ! -f "$HOME/.config/VSCodium/User/settings.json" ]; then
  mkdir -p $HOME/.config/VSCodium/User
  cat << EOF > $HOME/.config/VSCodium/User/settings.json
{
  "editor.minimap.enabled": false,
  "python.experiments.enabled": false,
  "robocorp.verifyLSP": true,
  "robot.codeLens.enabled": true,
  "terminal.integrated.inheritEnv": false
}
EOF
fi
if [ ! -f "$HOME/.config/Code/User/settings.json" ]; then
  mkdir -p $HOME/.config/Code/User
  cat << EOF > $HOME/.config/Code/User/settings.json
{
  "editor.minimap.enabled": false,
  "python.experiments.enabled": false,
  "robocorp.verifyLSP": true,
  "robot.codeLens.enabled": true,
  "terminal.integrated.inheritEnv": false
}
EOF
fi

# ~/.bashrc
if [ ! -f "$HOME/.bashrc" ]; then
  cat << EOF > $HOME/.bashrc
alias wrap="echo 'rcc robot wrap'; rcc robot wrap; touch ."
alias feel-repl="amm --predef $HOME/.config/playground/feel-repl.sc"
zeebe-reset () {
  echo "Zeebe being shut down."
  sudo systemctl stop zeebe-play
  sudo systemctl stop zeebe-simple-monitor
  sudo systemctl stop postgresql
  sudo systemctl stop zeebe
  echo "Zeebe data being cleared."
  sudo rm -rf /var/lib/zeebe /var/lib/postgresql
  echo "Zeebe getting back online."
  sudo systemctl start zeebe
  sudo systemctl start postgresql
  sudo systemctl start zeebe-simple-monitor-init
  sudo systemctl start zeebe-simple-monitor
  sudo systemctl start zeebe-play-init
  sudo systemctl start zeebe-play
  while ! nc -z localhost 8081; do echo "..."; sleep 5; done
  echo "Zeebe is back."
}
EOF
fi

# Default panel
if [ ! -f "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml" ]; then
  mkdir -p $HOME/.config/xfce4/xfconf/xfce-perchannel-xml
  cat << EOF > $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="dark-mode" type="bool" value="true"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=8;x=959;y=1064"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="icon-size" type="uint" value="16"/>
      <property name="size" type="uint" value="26"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
      </property>
      <property name="disable-struts" type="bool" value="false"/>
      <property name="mode" type="uint" value="0"/>
      <property name="autohide-behavior" type="uint" value="0"/>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-2" type="string" value="tasklist">
      <property name="grouping" type="uint" value="0"/>
      <property name="show-labels" type="bool" value="true"/>
      <property name="flat-buttons" type="bool" value="true"/>
      <property name="show-handle" type="bool" value="false"/>
      <property name="include-all-workspaces" type="bool" value="true"/>
      <property name="include-all-monitors" type="bool" value="true"/>
      <property name="show-only-minimized" type="bool" value="false"/>
    </property>
    <property name="plugin-1" type="string" value="showdesktop"/>
  </property>
</channel>
EOF
fi
          '';
        };
        programs.vscode.enable = true;
        programs.vscode.package = ((if config.options.vscode-unfree then pkgs.vscode-fhsWithPackages else pkgs.vscodium-fhsWithPackages) (ps: with ps; [
          (ps.python3Full.withPackages(ps: [(robotframework ps)]))
          pkgs.rcc
          # Inject enough dependencies to make robotframework-browser work
          pkgs.alsa-lib
          pkgs.at-spi2-atk
          pkgs.cairo
          pkgs.cups
          pkgs.dbus
          pkgs.expat
          pkgs.glib
          pkgs.libdrm
          pkgs.libudev0-shim
          pkgs.libxkbcommon
          pkgs.mesa
          pkgs.nspr
          pkgs.nss
          pkgs.pango
          pkgs.wayland
          pkgs.xorg.libX11
          pkgs.xorg.libXcomposite
          pkgs.xorg.libXdamage
          pkgs.xorg.libXext
          pkgs.xorg.libXfixes
          pkgs.xorg.libXrandr
          pkgs.xorg.libxcb
        ]));
        programs.vscode.extensions = (with pkgs.vscode-extensions; [
          ms-python.python
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension rec {
            mktplcRef = {
              name = "robotframework-lsp";
              publisher = "robocorp";
              version = "1.7.3";
              sha256 = "sha256-Ssu88xKHBCvz4CsR/qITMbMK56UJPoDfvTIzdVXpIg0=";
            };
          })
          (pkgs.vscode-utils.buildVscodeMarketplaceExtension rec {
            mktplcRef = {
              name = "robocorp-code";
              publisher = "robocorp";
              version = "0.42.1";
              sha256 = "sha256-CKqfSH0d1hjplksYKMsQ22HMVbO697mE1v17K2c7Hk4=";
            };
            postInstall = ''
              # Use nix built RCC
              mkdir -p $out/share/vscode/extensions/robocorp.robocorp-code/bin
              ln -s ${pkgs.rcc}/bin/rcc $out/share/vscode/extensions/robocorp.robocorp-code/bin
              # Patch code env to make inspectors work
              substituteInPlace $out/share/vscode/extensions/robocorp.robocorp-code/bin/create_env/conda_vscode_linux_amd64.yaml \
                --replace "- openssl>=3.0.7" "- openssl" \
                --replace "- pyqt" "# pyqt"
              substituteInPlace $out/share/vscode/extensions/robocorp.robocorp-code/bin/create_env/get_env_info.py \
                --replace "dict(os.environ)" "dict(os.environ) | {'GI_TYPELIB_PATH': ':'.join([os.environ['GI_TYPELIB_PATH'], '${pkgs.webkitgtk}/lib/girepository-1.0', '${pkgs.gnome.libsoup}/lib/girepository-1.0']), 'PYTHONPATH': '${pkgs.python39Packages.pygobject3}/lib/python3.9/site-packages/'}" \
                --replace "flush()" "flush(); from pathlib import Path; import sys; p=Path(f'{sys.prefix}/lib/python3.9/site-packages/inspector/windows/base.py'); p.write_text(p.read_text().replace('resizable=False', 'resizable=True'))"
            '';
            })
        ] ++ (if config.options.vscode-with-vim then [ vscodevim.vim ] else []))
          ++ (if config.options.vscode-unfree then [ pkgs.vscode-extensions.ms-vsliveshare.vsliveshare ] else []);
      };
    }];

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ([
    ] ++ lib.lists.optionals config.options.vscode-unfree [
      "code"
      "vscode"
      "vscode-extension-ms-vsliveshare-vsliveshare"
    ]);
  };
}
