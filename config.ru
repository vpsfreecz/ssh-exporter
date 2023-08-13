require 'ssh-exporter/rackup'

run SshExporter::Rackup.app(ENV['SSH_EXPORTER_CONFIG'] || 'config-sample.json')
