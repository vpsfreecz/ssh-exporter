module SshExporter
  class Collector
    def initialize(config, registry)
      @config = config
      @registry = registry

      @up = @registry.gauge(
        :ssh_host_up,
        docstring: '1 if the host is up, 0 otherwise',
        labels: %i[alias fqdn]
      )

      @last_check = @registry.gauge(
        :ssh_host_last_check,
        docstring: 'Timestamp of the last check',
        labels: %i[alias fqdn]
      )

      @check_seconds = @registry.gauge(
        :ssh_host_check_seconds,
        docstring: 'Number of seconds the check took',
        labels: %i[alias fqdn]
      )

      @load1 = @registry.gauge(
        :ssh_host_load1,
        docstring: 'One minute load average',
        labels: %i[alias fqdn]
      )

      @load5 = @registry.gauge(
        :ssh_host_load5,
        docstring: 'Five minute load average',
        labels: %i[alias fqdn]
      )

      @load15 = @registry.gauge(
        :ssh_host_load15,
        docstring: 'Fifteen minute load average',
        labels: %i[alias fqdn]
      )
    end

    def start
      @threads = @config.hosts.each_value.map do |host|
        sleep(1)

        Thread.new do
          loop do
            check_host(host)
            sleep(host.interval)
          end
        end
      end
    end

    protected

    def check_host(host)
      cmd = %W[
        ssh
        -o StrictHostKeyChecking=no
        -o UserKnownHostsFile=/dev/null
        -o ConnectTimeout=#{host.timeout}
        -o PasswordAuthentication=no
        -o ServerAliveInterval=3
        -o ServerAliveCountMax=1
        -T
        -l "#{host.user}"
        -i "#{host.private_key_file}"
        "#{host.fqdn}"
        cat /proc/loadavg
      ]

      output = ''

      labels = {
        alias: host.alias_name,
        fqdn: host.fqdn
      }

      t1 = Time.now

      IO.popen(cmd.join(' '), 'r') do |io|
        output = io.read.strip
      end

      t2 = Time.now
      success = $?.exitstatus == 0

      @up.set(success ? 1 : 0, labels:)
      @last_check.set(t1.to_i, labels:)
      @check_seconds.set(t2 - t1, labels:)

      if success
        load_averages = output.split(' ')[0..2].map(&:to_f)

        @load1.set(load_averages[0], labels:)
        @load5.set(load_averages[1], labels:)
        @load15.set(load_averages[2], labels:)
      else
        warn "#{host.fqdn}: failed with exit status #{$?.exitstatus}"
      end
    end
  end
end
