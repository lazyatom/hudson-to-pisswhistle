require "test_helper"

context "Given a build.xml file in a workspace, when running the script" do
  include HudsonBuildHelper

  def build_xml_string
    %{<build>
        <result>SUCCESS</result>
      </build>}.strip
  end

  def changelog
    "Changes between abc and def"
  end

  def project_name
    "test-project"
  end

  setup do
    setup_workspace(project_name)
    setup_build_xml_for(project_name, build_xml_string, changelog)

    ENV["STREAM"] = "test"
    ENV["HOST"] = nil
    ENV["OAUTH_TOKEN"] = "token"

    @net_lib = stub('net-library', :post => nil)
  end

  doing { HudsonToPissWhistle.run(@net_lib) }

  %w(STREAM OAUTH_TOKEN WORKSPACE BUILD_ID).each do |setting|
    raises "if no #{setting} is set in the environment" do
      ENV[setting] = nil
    end
  end

  expect "post to localhost by defalt" do
    @net_lib.expects(:post).with(regexp_matches(%r{^http://localhost/test/messages}), anything)
  end

  expect "post to an explicitly-provided HOST" do
    ENV["HOST"] = "flibble:1234"
    @net_lib.expects(:post).with(regexp_matches(%r{^http://flibble:1234/test/messages}), anything)
  end

  expect "post to an explicitly provided STREAM" do
    ENV["STREAM"] = "freerange"
    @net_lib.expects(:post).with(regexp_matches(%r{^http://localhost/freerange/messages}), anything)
  end

  expect "post to include a type parameter of 'hudson'" do
    @net_lib.expects(:post).with(anything, has_entry(:query => has_entry(:type => 'hudson')))
  end

  expect "post to include an oauth token" do
    @net_lib.expects(:post).with(anything, has_entry(:query => has_entry(:oauth_token => 'token')))
  end

  expect "post to include an explicitly provided oauth token" do
    ENV["OAUTH_TOKEN"] = "another-token"
    @net_lib.expects(:post).with(anything, has_entry(:query => has_entry(:oauth_token => 'another-token')))
  end

  context "the posted data" do
    setup do
      class Capture
        attr_reader :payload
        def post(url, query)
          @payload = JSON.parse(query[:query][:payload])
        end
      end
      @net_lib = Capture.new
      HudsonToPissWhistle.run(@net_lib)
    end

    should "include the changelog" do
      assert_equal changelog, @net_lib.payload["changelog"]
    end

    should "include a successful build message" do
      assert_equal "test-project (def) built successfully", @net_lib.payload["message"]
    end

    should "include a top-level success for compatibility with ci messages" do
      assert_equal "SUCCESS", @net_lib.payload["result"]
    end

    context "when some xml keys with dots exist" do
      def build_xml_string
        %{<build>
            <result>SUCCESS</result>
            <another.key>blah</another.key>
          </build>}.strip
      end

      should "convert xml keys with dots to dashes" do
        assert_equal "blah", @net_lib.payload["build"]["another-key"]
      end
    end

    context "when the build failed" do
      def build_xml_string
        %{
          <build>
            <result>FAILURE</result>
            <another.key>blah</another.key>
          </build>
        }
      end

      should "include a failure message" do
        assert_equal "test-project (def) failed!", @net_lib.payload["message"]
      end
    end
  end

  teardown { teardown_project(project_name) }
end