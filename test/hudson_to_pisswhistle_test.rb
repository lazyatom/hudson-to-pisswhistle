require "test_helper"

context "Given a build.xml file in a workspace" do
  include HudsonBuildHelper

  setup do
    setup_workspace("project")
    @build_xml = setup_build_xml_for("project", %{
      <build>
        <result>SUCCESS</result>
        <another.key>blah</another.key>
      </build>
    },"The change message for this build")

    ENV["STREAM"] = "test"
    ENV["HOST"] = nil
    ENV["OAUTH_TOKEN"] = "token"

    @net_lib = stub('net-library', :post => nil)
  end

  context "when running the script" do
    doing { HudsonToPissWhistle.run(@net_lib) }

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

    expect "post build XML data and changelog as JSON, changing dots in xml keys to be converted to dashes because BSON hates them" do
      xml_as_hash = {:build => {:result => "SUCCESS", "another-key" => "blah"}}
      xml_as_json = xml_as_hash.merge(:message => "The change message for this build", :result => "SUCCESS").to_json
      @net_lib.expects(:post).with(anything, has_entry(:query => has_entry(:payload => matching_json(xml_as_json))))
    end

    %w(STREAM OAUTH_TOKEN WORKSPACE BUILD_ID).each do |setting|
      raises "if no #{setting} is set in the environment" do
        ENV[setting] = nil
      end
    end
  end

  teardown { teardown_project("project") }
end