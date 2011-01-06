require "rubygems"
require "bundler/setup"
require "kintama"
require "mocha"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "hudson_to_pisswhistle"

module HudsonBuildHelper
  def setup_workspace(project_name)
    workspace_path = "/tmp/test/#{project_name}/workspace"
    FileUtils.mkdir_p(workspace_path)
    ENV["WORKSPACE"] = workspace_path
  end

  def setup_build_xml_for(project_name, xml, changelog)
    build_id = "2011_01_05_15_23"
    build_path = "/tmp/test/#{project_name}/builds/#{build_id}"
    FileUtils.mkdir_p(build_path)
    File.open(File.join(build_path, "build.xml"), "w") do |f|
      f.write %|
      <?xml version='1.0' encoding='UTF-8'?>
      #{xml}
      |.strip
    end
    File.open(File.join(build_path, "changelog.xml"), "w") do |f|
      f.puts changelog
    end
    ENV["BUILD_ID"] = build_id
  end

  def teardown_project(project_name)
    FileUtils.rm_rf("/tmp/test/#{project_name}")
  end
end

module Doing
  def doing(&block)
    @doing = block
  end

  def should_change(&block)
    doing_block = @doing
    should "change something" do
      previous_value = instance_eval(&block)
      instance_eval(&doing_block)
      subsequent_value = instance_eval(&block)
      assert subsequent_value != previous_value, "it didn't change"
    end
  end

  def expect(name, &block)
    doing_block = @doing
    test "expect #{name}" do
      instance_eval(&block)
      instance_eval(&doing_block)
    end
  end
end

Kintama.extend Doing

Kintama.include HudsonBuildHelper

Kintama.include Mocha::API
Kintama.teardown do
  begin
    mocha_verify
  rescue Mocha::ExpectationError => e
    raise e
  ensure
    mocha_teardown
  end
end

module Mocha
  module ParameterMatchers
    def matching_json(expected)
      MatchingJSON.new(expected)
    end
    class MatchingJSON < Base
      def initialize(expected)
        @expected = expected
      end

      def matches?(available_parameters)
        parameter = available_parameters.shift
        actual = JSON.parse(parameter)
        expected = JSON.parse(@expected)
        actual == expected
      end

      def mocha_inspect
        "matching_json(...)"
      end
    end
  end
end