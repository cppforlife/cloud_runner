require "cloud_runner/ssh_key"
require "cloud_runner/digital_ocean/cli/base"

module CloudRunner::DigitalOcean::Cli
  class New < Base
    SHORT_HOST_IMAGE_NAMES = {
      "ubuntu-10-04" => "Ubuntu 10.04 x64 Server",
      "ubuntu-12-04" => "Ubuntu 12.04 x64 Server",
      "centos-6-3"   => "CentOS 6.3 x64",
    }.freeze

    def initialize(opts={})
      super

      raise "Host image must be specified" \
        unless @host_image = options[:host_image]

      raise "Host image is not available" \
        unless @image_name = SHORT_HOST_IMAGE_NAMES[@host_image]
    end

    protected

    def set_up
      step("Creating ssh key '#{ssh_key.private_path}'") do
        run.create_ssh_key(ssh_key)
      end

      step("Creating droplet '#{run.name}'") do
        run.create_droplet(:image_name => @image_name)
      end
    end

    # Since we created ssh key/droplet
    # assume that's it is safe to delete.
    def clean_up
      if options[:keep_droplet]
        step("Skipping deletion of droplet and ssh key")
      else
        step("Deleting droplet") { run.delete_droplet }
        step("Deleting ssh key") { run.delete_ssh_key }
      end
    end

    def ssh_key
      @ssh_key ||= CloudRunner::SshKey.new
    end
  end
end
