{ pkgs, lib, config, utils, ... }:

with lib;

let
  cfg = config.services.gmediarender;
in
{
  options.services.gmediarender = {
    enable = mkEnableOption (mdDoc "the gmediarender DLNA renderer");

    audioDevice = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc ''
        The audio device to use.
      '';
    };

    audioSink = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc ''
        The audio sink to use.
      '';
    };

    friendlyName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc ''
        A "friendly name" for identifying the endpoint.
      '';
    };

    initialVolume = mkOption {
      type = types.nullOr types.int;
      default = 0;
      description = mdDoc ''
        A default volume attenuation (in dB) for the endpoint.
      '';
    };

    package = mkPackageOptionMD pkgs "gmediarender" {
      default = "gmrender-resurrect";
    };

    port = mkOption {
      type = types.nullOr types.port;
      default = null;
      description = mdDoc "Port that will be used to accept client connections.";
    };

    uuid = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc ''
        A UUID for uniquely identifying the endpoint.  If you have
        multiple renderers on your network, you MUST set this.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      services.gmediarender = {
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        description = "gmediarender server daemon";
        environment = {
          XDG_CACHE_HOME = "%t/gmediarender";
        };
        serviceConfig = {
          DynamicUser = true;
          User = "gmediarender";
          Group = "gmediarender";
          SupplementaryGroups = [ "audio" ];
          ExecStart =
            "${cfg.package}/bin/gmediarender " +
            optionalString (cfg.audioDevice != null) ("--gstout-audiodevice=${utils.escapeSystemdExecArg cfg.audioDevice} ") +
            optionalString (cfg.audioSink != null) ("--gstout-audiosink=${utils.escapeSystemdExecArg cfg.audioSink} ") +
            optionalString (cfg.friendlyName != null) ("--friendly-name=${utils.escapeSystemdExecArg cfg.friendlyName} ") +
            optionalString (cfg.initialVolume != 0) ("--initial-volume=${toString cfg.initialVolume} ") +
            optionalString (cfg.port != null) ("--port=${toString cfg.port} ") +
            optionalString (cfg.uuid != null) ("--uuid=${utils.escapeSystemdExecArg cfg.uuid} ");
          Restart = "always";
          RuntimeDirectory = "gmediarender";

          # Security options:
          NoNewPrivileges = true;
          SystemCallArchitectures = "native";
          RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          LockPersonality = true;
          PrivateTmp = true;
          PrivateDevices = true;
          PrivateUsers = true;
          RemoveIPC = true;
          CapabilityBoundingSet = "";
          SystemCallFilter = [
            "~@clock"
            "~@aio"
            "~@chown"
            "~@cpu-emulation"
            "~@debug"
            "~@keyring"
            "~@memlock"
            "~@module"
            "~@mount"
            "~@obsolete"
            "~@privileged"
            "~@raw-io"
            "~@reboot"
            "~@setuid"
            "~@swap"
          ];
          SystemCallErrorNumber = "EPERM";
        };
      };
    };
  };
}
