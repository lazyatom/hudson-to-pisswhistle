require 'rubygems'
require 'httparty'
require 'crack'
require 'json'

class HudsonToPissWhistle
  # Hudson's XML keys contain dots, but BSON doesn't like that.
  def self.change_dots_to_hyphens_in_keys(hash)
    hash.inject({}) do |h, (k,v)|
      h[k.to_s.gsub(".", "-")] = v.is_a?(Hash) ? change_dots_to_hyphens_in_keys(v) : v
      h
    end
  end

  def self.run(net_client=HTTParty)
    %w(STREAM OAUTH_TOKEN WORKSPACE BUILD_ID).each do |setting|
      raise "#{setting} was not set" unless ENV[setting]
    end

    project_name = ENV["WORKSPACE"].split("/")[-2]
    build_directory = File.expand_path(File.join(ENV["WORKSPACE"], "..", "builds", ENV["BUILD_ID"]))
    build_log = File.join(build_directory, "build.xml")

    # puts "sleeping while i wait for build.xml to appear"
    x = 0
    until File.exists?(build_log) || x > 10 do
      sleep(1)
      # puts "chekcing for #{build_log}"
      x += 1
    end
    # puts "awake again #{x}"

    data = Crack::XML.parse(File.read(build_log))

    data = change_dots_to_hyphens_in_keys(data)

    data["changelog"] = File.read(File.join(build_directory, "changelog.xml")).strip
    revision = data["changelog"].split(" ").last
    data["message"] = if data["build"]["result"] == "SUCCESS"
      "#{project_name} (#{revision}) built successfully"
    else
      "#{project_name} (#{revision}) failed!"
    end

    # legacy CI message compatibility
    data["result"] = data["build"]["result"]

    stream_url = "http://#{ENV["HOST"] || "localhost"}/#{ENV["STREAM"]}/messages"
    query = {:type => "hudson", :oauth_token => ENV["OAUTH_TOKEN"], :payload => data.to_json}
    net_client.post(stream_url, :query => query)
  end
end