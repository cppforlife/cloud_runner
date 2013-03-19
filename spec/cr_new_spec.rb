require "spec_helper"
require "stringio"
require "cloud_runner/digital_ocean/cli/new"

describe "cr-new" do
  let(:client_id) { ENV["SPEC_CR_CLIENT_ID"] || raise }
  let(:api_key) { ENV["SPEC_CR_API_KEY"] || raise }

  def self.it_runs_script(script, expected_exit_code)
    describe "for '#{script}' script" do
      let(:out) { StringIO.new }
      let(:err) { StringIO.new }

      it "runs script and returns exit code" do
        CloudRunner::DigitalOcean::Cli::New.new(
          :client_id => client_id,
          :api_key => api_key,
          :script => "./spec/fixtures/#{script}.sh",
          :host_image => "ubuntu-10-04",
        ).run_script(
          Multiplexer.new(out, $stdout),
          Multiplexer.new(err, $stderr),
        ).should == expected_exit_code

        out.string.should include("Echo to stdout\n")
        err.string.should include("Echo to stderr\n")
      end
    end
  end

  it_runs_script "success", 0
  it_runs_script "fail", 128
end
