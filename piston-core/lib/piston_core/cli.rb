require "rubygems"
require "pathname"

PISTON_CORE_ROOT = Pathname.new(File.dirname(__FILE__)).realpath.parent.parent
$:.unshift(PISTON_CORE_ROOT + "lib")

require "piston_core"
require "piston_core/version"

require "piston_core/repository"
require "piston_core/working_copy"
require "piston_core/commands/import"

require "main"

Main {
  program "piston"
  author "François Beausoleil <francois@teksol.info>"
  version PistonCore::VERSION::STRING

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
      description "The revision you wish to operate on"
    end

    option "commit" do
      argument_required
      default "HEAD"
      description "The commit you wish to operate on"
    end

    def target_revision
      case
      when params["revision"].given?
        params["revision"].value
      when params["commit"].given?
        params["commit"].value
      else
        :head
      end
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

    logger_level Logger::DEBUG
    def run
      if params["revision"].given? && params["commit"].given? then
        raise ArgumentError, "Only one of --revision or --commit can be given.  Received both."
      end

      set_loggers!

      cmd = PistonCore::Commands::Import.new(:lock => params["lock"].value,
                                         :verbose => params["verbose"].value,
                                         :quiet => params["quiet"].value,
                                         :force => params["force"].value,
                                         :dry_run => params["dry-run"].value)
      repository = PistonCore::Repository.guess(params[:repository].value)
      revision = repository.at(self.target_revision)
      working_copy = PistonCore::WorkingCopy.guess(params[:directory].value)

      cmd.run(revision, working_copy)
    end
  end

  option("version", "v")

  def run
    if params["version"].given? || ARGV.first == "version" then
      puts PistonCore.version_message
      exit_success!
    elsif ARGV.empty?
      puts PistonCore.version_message
      puts "\nNo mode given.  Call with help to find out the available options."
      exit_failure!
    else
      puts "Unrecognized mode: #{ARGV.first.inspect}.  Use the help mode to find the available options."
      exit_warn!
    end
  end

  def set_loggers!
    PistonCore::Repository.logger = logger
    PistonCore::WorkingCopy.logger = logger
    PistonCore::Commands::Base.logger = logger
  end
}
