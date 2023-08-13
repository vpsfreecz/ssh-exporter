require 'prometheus/client'

module SshExporter
  def self.registry
    @registry ||= Prometheus::Client::Registry.new
  end
end

require_relative 'ssh-exporter/config'
require_relative 'ssh-exporter/collector'
require_relative 'ssh-exporter/version'
