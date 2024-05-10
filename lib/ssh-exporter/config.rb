require 'json'

module SshExporter
  # ssh-exporter's config
  class Config
    class Host
      # @return [String]
      attr_reader :name

      # @return [String]
      attr_reader :alias_name

      # @return [String]
      attr_reader :fqdn

      # @return [String]
      attr_reader :user

      # @return [String]
      attr_reader :private_key_file

      # @return [Integer]
      attr_reader :interval

      # @return [Integer]
      attr_reader :timeout

      def initialize(name:, alias_name:, fqdn:, user:, private_key_file:, interval:, timeout:)
        @name = name
        @alias_name = alias_name
        @fqdn = fqdn
        @user = user
        @private_key_file = private_key_file
        @interval = interval
        @timeout = timeout
      end
    end

    # @return [Hash<String, Host>]
    attr_reader :hosts

    def initialize(path)
      data = JSON.parse(File.read(path))

      @hosts = data['hosts'].to_h do |k, v|
        h = Host.new(
          name: k,
          alias_name: v.fetch('alias'),
          fqdn: v.fetch('fqdn'),
          user: v.fetch('user'),
          private_key_file: v.fetch('private_key_file'),
          interval: v.fetch('interval', 60),
          timeout: v.fetch('timeout', 30)
        )
        [h.name, h]
      end
    end
  end
end
