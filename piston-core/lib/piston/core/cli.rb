require "rubygems"
require "pathname"

PISTON_CORE_ROOT = Pathname.new(File.dirname(__FILE__)).realpath.parent.parent.parent
$:.unshift(PISTON_CORE_ROOT + "lib")

require "piston"
require "piston/core"
require "piston/core/version"

require "main"

Main {
  program "piston"
  author "François Beausoleil <francois@teksol.info>"

  mixin :standard_options do
    option("verbose", "v") { default false }
    option("quiet", "q") { default false }
    option("force") { default false }
    option("dry-run") { default false }
  end

  mixin :revision_or_commit do
    option "revision", "r" do
      argument_required
      default "HEAD"
      description "The revision you wish to import"
    end

    option "commit" do
      argument_required
      default "HEAD"
      description "The commit you wish to import"
    end
  end

  mode "import" do
    mixin :standard_options
    mixin :revision_or_commit

    argument "repository" do
      required
      description "The repository you wish to Pistonize"
    end 

    argument "directory" do
      optional
      default :repository
      description "Where to put the Pistonized repository"
    end

    option("lock") do
      default false
      description "Automatically lock down the revision/commit to protect against blanket updates"
    end

    def run
      puts "running import"
      puts "repos: #{params["repository"].value.inspect}"
      puts "dir:   #{params["directory"].value.inspect}"
      puts "revision: #{params["revision"].value.inspect}"
      puts "commit: #{params["commit"].value.inspect}"
      puts "verbose: #{params["verbose"].value.inspect}"
      puts "quiet: #{params["quiet"].value.inspect}"
      puts "force: #{params["force"].value.inspect}"
      puts "dry-run: #{params["dry-run"].value.inspect}"
      puts "lock: #{params["lock"].value.inspect}"

      if params["revision"].given? && params["commit"].given? then
        raise ArgumentError, "Only one of --revision or --commit can be given.  Received both."
      end
    end
  end

  version Piston::Core::VERSION::STRING
  option("version", "v")

  def run
    if params["version"].given? || ARGV.first == "version" then
      puts Piston::Core.version_message
      exit_success!
    elsif ARGV.empty?
      puts Piston::Core.version_message
      puts "\nNo mode given.  Call with help to find out the available options."
      exit_failure!
    else
      puts "Unrecognized mode: #{ARGV.first.inspect}.  Use the help mode to find the available options."
      exit_warn!
    end
  end
}
