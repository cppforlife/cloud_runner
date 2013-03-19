require "securerandom"
require "cloud_runner/ssh"
require "cloud_runner/digital_ocean/base"

module CloudRunner::DigitalOcean
  class Run
    DROPLET_DEFAULT_NAMES = {
      :region => "New York 1",
      :image => "Ubuntu 12.04 x64 Server",
      :size => "512MB",
    }.freeze

    def initialize(api)
      @api = api
    end

    def name
      @name ||= "run-#{SecureRandom.hex}"
    end

    def create_ssh_key(ssh_key)
      use_ssh_key(ssh_key)

      @public_ssh_key ||= @api.ssh_keys.add(
        :name => "#{name}-ssh-key",
        :ssh_pub_key => ssh_key.public,
      ).ssh_key
    end

    def use_ssh_key(ssh_key)
      raise "Ssh key must specified" unless @ssh_key = ssh_key
    end

    def delete_ssh_key
      @api.ssh_keys.delete(@public_ssh_key.id) if @public_ssh_key
    end

    def create_droplet(opts={})
      raise "Ssh key must be created" unless @public_ssh_key

      attrs = extract_droplet_attrs(opts)

      @droplet ||= @api.droplets.create(
        :name => "#{name}-droplet",
        :region_id => attrs[:region].id,
        :image_id => attrs[:image].id,
        :size_id => attrs[:size].id,
        :ssh_key_ids => "#{@public_ssh_key.id}",
      ).droplet

      wait_for_droplet_to_be_alive
    end

    def find_droplet_by_id(droplet_id)
      raise "Droplet id must be specified" unless droplet_id

      @droplet ||= @api.droplets.show(droplet_id).droplet

      wait_for_droplet_to_be_alive
    end

    def delete_droplet
      @api.droplets.delete(@droplet.id) if @droplet
    end

    def run_script(local_path, out, err, opts={})
      raise "Droplet must be created" unless @droplet
      raise "Local path must be specified" unless local_path

      ssh = CloudRunner::Ssh.new(@droplet.ip_address, "root", @ssh_key)
      ssh.run_script(local_path, out, err, opts)
    end

    private

    def extract_droplet_attrs(opts)
      {}.tap do |attrs|
        DROPLET_DEFAULT_NAMES.each do |field, name|
          find_method_name = "find_#{field}_by_name"
          find_name = opts[:"#{field}_name"] || name

          record = @api.send(find_method_name, find_name)
          raise "#{field} was not found" \
            unless attrs[field] = record
        end
      end
    end

    def wait_for_droplet_to_be_alive
      wait_for_droplet { |d| d.ip_address && d.status == "active" }
    end

    def wait_for_droplet(&blk)
      raise "Droplet must be created" unless @droplet

      Timeout.timeout(180) do
        while !blk.call(@droplet) && sleep(5)
          @droplet = @api.droplets.show(@droplet.id).droplet
        end
      end

      @droplet
    end
  end
end
