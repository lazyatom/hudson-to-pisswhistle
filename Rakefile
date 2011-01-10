require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"

task :default => :test

task :test do
  tests = Dir["test/**/*.rb"]
  exec "ruby -Itest #{tests.join(" ")}"
end

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "hudson-to-pisswhistle"
  s.version           = "0.1.2"
  s.summary           = "Gathers build data from hudson and posts it to a URL"
  s.author            = "James Adam, James Mead"
  s.email             = "james@lazyatom.com"
  s.homepage          = "http://gofreerange.com"

  s.has_rdoc          = true
  # You should probably have a README of some kind. Change the filename
  # as appropriate
  s.extra_rdoc_files  = %w(README)
  s.rdoc_options      = %w(--main README)

  # Add any extra files to include in the gem (like your README)
  s.files             = %w(README) + Dir.glob("{bin,lib}/**/*")
  s.executables       = FileList["bin/**"].map { |f| File.basename(f) }

  # You need to put your code in a directory which can then be added to
  # the $LOAD_PATH by rubygems. Typically this is lib, but you don't seem
  # to have that directory. You'll need to set the line below to whatever
  # directory your code is in. Rubygems is going to assume lib if you leave
  # this blank.
  #
  s.require_paths = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("httparty", "~> 0.6.1")
  s.add_dependency("crack", "~> 0.1.8")
  s.add_dependency("json", "~> 1.4.6")

  # If your tests use any gems, include them here
  s.add_development_dependency("kintama", "~> 0.1.1")
  s.add_development_dependency("mocha", "~> 0.9")
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more 
# about that here: http://gemcutter.org/pages/gem_docs
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

# If you don't want to generate the .gemspec file, just remove this line. Reasons
# why you might want to generate a gemspec:
#  - using bundler with a git source
#  - building the gem without rake (i.e. gem build blah.gemspec)
#  - maybe others?
task :package => :gemspec

# Generate documentation
Rake::RDocTask.new do |rd|
  
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end

desc 'Tag the repository in git with gem version number'
task :tag => [:gemspec, :package] do
  if `git diff --cached`.empty?
    if `git tag`.split("\n").include?("v#{spec.version}")
      raise "Version #{spec.version} has already been released"
    end
    `git add #{File.expand_path("../#{spec.name}.gemspec", __FILE__)}`
    `git commit -m "Released version #{spec.version}"`
    `git tag v#{spec.version}`
    `git push --tags`
    `git push`
  else
    raise "Unstaged changes still waiting to be committed"
  end
end

desc "Tag and publish the gem to rubygems.org"
task :publish => :tag do
  `gem push pkg/#{spec.name}-#{spec.version}.gem`
end