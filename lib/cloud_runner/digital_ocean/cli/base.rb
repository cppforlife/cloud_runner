require "cloud_runner/ssh_key"
require "cloud_runner/digital_ocean/base"
require "cloud_runner/digital_ocean/api"
require "cloud_runner/digital_ocean/run"

module CloudRunner::DigitalOcean
  module Cli
    class Base
      attr_reader :options

      def initialize(opts={})
        @options = opts.clone.freeze

        raise "Client id must be specified" \
          unless @client_id = options[:client_id]

        raise "Api key must be specified" \
          unless @api_key = options[:api_key]

        raise "Script must be specified" \
          unless @script_path = options[:script]

        @script_path = File.realpath(@script_path)
      end

      def run_script(out, err)
        @out, @err = out, err

        set_up
        execute_script
      ensure
        clean_up
      end

      protected

      def set_up
        raise NotImplementedError
      end

      def execute_script
        step("Executing script '#{@script_path}'") do
          run.run_script(@script_path, @out, @err)
        end
      end

      def clean_up
        raise NotImplementedError
      end

      def run
        @ci_run ||= Run.new(api)
      end

      def ssh_key
        raise NotImplementedError
      end

      def step(description, &action)
        @out.puts("-----> #{description}...")

        action.call.tap do |result|
          @out.puts(result)
        end if action
      end

      private

      def api
        @api ||= Api.new(@client_id, @api_key)
      end
    end

    #~
  end
end
