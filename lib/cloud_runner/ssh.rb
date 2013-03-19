require "securerandom"
require "stringio"
require "net/ssh"
require "net/scp"

module CloudRunner
  class Ssh
    DEFAULT_OPTIONS = {
      :auth_methods => ["publickey"],
      :paranoid => false,
    }.freeze

    def initialize(host, user, ssh_key)
      raise "Host must be specified" unless @host = host
      raise "User must be specified" unless @user = user
      raise "Key must be specified"  unless @ssh_key = ssh_key
    end

    def run_script(local_path, out, err, opts={})
      ssh_opts = DEFAULT_OPTIONS.clone.merge(
        :keys => [@ssh_key.private_path],
        :host_key => "ssh-#{@ssh_key.type}",
        :logger => opts[:ssh_logger] || StringIO.new,
        :verbose => :debug,
      )

      # Assume the worst
      @exit_code = 1

      Net::SSH.start(@host, @user, ssh_opts) do |ssh|
        ssh.scp.upload!(local_path, remote_path)
        ssh.exec!("chmod +x #{remote_path}")
        full_exec(ssh, remote_path, out, err)
      end

      @exit_code
    end

    private

    def remote_path
      @remote_path ||= "/tmp/run-#{SecureRandom.hex}.sh"
    end

    def full_exec(ssh, command, out, err)
      channel_exec(ssh, command) do |ch|
        stream_stdout(ch, out)
        stream_stderr(ch, err)
        handle_exit(ch)
        handle_signal(ch)
      end
    end

    def channel_exec(ssh, command, &blk)
      ssh.open_channel do |channel|
        channel.exec(command) do |ch, success|
          return @exit_code = 1 unless success
          blk.call(ch)
        end
      end
      ssh.loop
    end

    def stream_stdout(channel, stream)
      channel.on_data do |ch, data|
        stream.print(data)
      end
    end

    def stream_stderr(channel, stream)
      channel.on_extended_data do |ch, type, data|
        stream.print(data)
      end
    end

    def handle_exit(channel)
      channel.on_request("exit-status") do |ch, data|
        @exit_code = data.read_long
      end
    end

    def handle_signal(channel)
      channel.on_request("exit-signal") do |ch, data|
        raise "Received signal: #{data.read_long}"
      end
    end

    #~
  end
end
