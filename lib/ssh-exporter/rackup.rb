require 'ssh-exporter'
require 'rack'
require 'prometheus/middleware/exporter'

module SshExporter
  module Rackup
    def self.app(config_file)
      Thread.abort_on_exception = true

      registry = SshExporter.registry

      collector = SshExporter::Collector.new(
        Config.new(config_file),
        registry,
      )
      collector.start

      Rack::Builder.app do
        use Rack::Deflater
        use Prometheus::Middleware::Exporter, {registry: registry}

        run ->(_) { [200, {'Content-Type' => 'text/html'}, ['OK']] }
      end
    end
  end
end
