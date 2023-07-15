class Pnmx::Cli::Traefik < Pnmx::Cli::Base
  desc "boot", "Boot Traefik on servers"
  def boot
    mutating do
      on(PNMX.traefik_hosts) do
        execute *PNMX.registry.login
        execute *PNMX.traefik.run, raise_on_non_zero_exit: false
      end
    end
  end

  desc "reboot", "Reboot Traefik on servers (stop container, remove container, start new container)"
  def reboot
    mutating do
      stop
      remove_container
      boot
    end
  end

  desc "start", "Start existing Traefik container on servers"
  def start
    mutating do
      on(PNMX.traefik_hosts) do
        execute *PNMX.auditor.record("Started traefik"), verbosity: :debug
        execute *PNMX.traefik.start, raise_on_non_zero_exit: false
      end
    end
  end

  desc "stop", "Stop existing Traefik container on servers"
  def stop
    mutating do
      on(PNMX.traefik_hosts) do
        execute *PNMX.auditor.record("Stopped traefik"), verbosity: :debug
        execute *PNMX.traefik.stop, raise_on_non_zero_exit: false
      end
    end
  end

  desc "restart", "Restart existing Traefik container on servers"
  def restart
    mutating do
      stop
      start
    end
  end

  desc "details", "Show details about Traefik container from servers"
  def details
    on(PNMX.traefik_hosts) { |host| puts_by_host host, capture_with_info(*PNMX.traefik.info), type: "Traefik" }
  end

  desc "logs", "Show log lines from Traefik on servers"
  option :since, aliases: "-s", desc: "Show logs since timestamp (e.g. 2013-01-02T13:23:37Z) or relative (e.g. 42m for 42 minutes)"
  option :lines, type: :numeric, aliases: "-n", desc: "Number of log lines to pull from each server"
  option :grep, aliases: "-g", desc: "Show lines with grep match only (use this to fetch specific requests by id)"
  option :follow, aliases: "-f", desc: "Follow logs on primary server (or specific host set by --hosts)"
  def logs
    grep = options[:grep]

    if options[:follow]
      run_locally do
        info "Following logs on #{PNMX.primary_host}..."
        info PNMX.traefik.follow_logs(host: PNMX.primary_host, grep: grep)
        exec PNMX.traefik.follow_logs(host: PNMX.primary_host, grep: grep)
      end
    else
      since = options[:since]
      lines = options[:lines].presence || ((since || grep) ? nil : 100) # Default to 100 lines if since or grep isn't set

      on(PNMX.traefik_hosts) do |host|
        puts_by_host host, capture(*PNMX.traefik.logs(since: since, lines: lines, grep: grep)), type: "Traefik"
      end
    end
  end

  desc "remove", "Remove Traefik container and image from servers"
  def remove
    mutating do
      stop
      remove_container
      remove_image
    end
  end

  desc "remove_container", "Remove Traefik container from servers", hide: true
  def remove_container
    mutating do
      on(PNMX.traefik_hosts) do
        execute *PNMX.auditor.record("Removed traefik container"), verbosity: :debug
        execute *PNMX.traefik.remove_container
      end
    end
  end

  desc "remove_image", "Remove Traefik image from servers", hide: true
  def remove_image
    mutating do
      on(PNMX.traefik_hosts) do
        execute *PNMX.auditor.record("Removed traefik image"), verbosity: :debug
        execute *PNMX.traefik.remove_image
      end
    end
  end
end
