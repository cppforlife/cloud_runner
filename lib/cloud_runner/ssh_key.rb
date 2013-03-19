require "securerandom"

module CloudRunner
  class SshKey
    attr_reader :type

    def initialize(type="rsa", private_path=nil)
      raise "Type must be specified" unless @type = type
      @private_path = private_path
    end

    def public
      File.read("#{private_path}.pub")
    end

    def private
      File.read(private_path)
    end

    def private_path
      unless @private_path
        @private_path = "/tmp/ssh-key-#{SecureRandom.hex}"
        generate
      end
      @private_path
    end

    private

    def generate
      `ssh-keygen -t '#{@type}' -f '#{@private_path}' -N ''`
      raise "Failed to generate ssh key" unless $? == 0
    end
  end
end
