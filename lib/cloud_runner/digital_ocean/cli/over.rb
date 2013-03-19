require "cloud_runner/ssh_key"
require "cloud_runner/digital_ocean/cli/base"

module CloudRunner::DigitalOcean::Cli
  class Over < Base
    def initialize(opts={})
      super

      raise "Droplet id must be specified" \
        unless @droplet_id = options[:droplet_id]

      raise "Ssh key must be specified" \
        unless @ssh_key_path = options[:ssh_key]

      @ssh_key_path = File.realpath(@ssh_key_path)
    end

    protected

    def set_up
      step("Using ssh key '#{ssh_key.private_path}'") do
        run.use_ssh_key(ssh_key)
      end

      step("Finding droplet '#{@droplet_id}'") do
        run.find_dropley_by_id(@droplet_id)
      end
    end

    # Nothing to clean up since we did not
    # create a new ssh/droplet.
    def clean_up
    end

    def ssh_key
      @ssh_key ||= CloudRunner::SshKey.new("rsa", @ssh_key_path)
    end
  end
end
