require "main"
require "log4r"
require "piston/version"
require "piston/commands"

Main {
  program "piston"
  author "François Beausoleil <francois@teksol.info>"
  version Piston::VERSION::STRING

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
      default nil
      description "Where to put the Pistonized repository"
    end

    option("lock") do
      default false
      description "Automatically lock down the revision/commit to protect against blanket updates"
    end

    logger_level Logger::DEBUG
    def run
      configure_logging!

      if params["revision"].given? && params["commit"].given? then
        raise ArgumentError, "Only one of --revision or --commit can be given.  Received both."
      end

      cmd = Piston::Commands::Import.new(:lock => params["lock"].value,
                                         :verbose => params["verbose"].value,
                                         :quiet => params["quiet"].value,
                                         :force => params["force"].value,
                                         :dry_run => params["dry-run"].value)
      cmd.run(params[:repository].value, self.target_revision, params[:directory].value)
    end
  end

  option("version", "v")

  def run
    if params["version"].given? || ARGV.first == "version" then
      puts Piston.version_message
      exit_success!
    elsif ARGV.empty?
      puts Piston.version_message
      puts "\nNo mode given.  Call with help to find out the available options."
      exit_failure!
    else
      puts "Unrecognized mode: #{ARGV.first.inspect}.  Use the help mode to find the available options."
      exit_warn!
    end
  end

  def configure_logging!
    Log4r::Logger.root.level = Log4r::ALL

    Log4r::Logger.new("main")
    Log4r::Logger.new("handler")
    Log4r::Logger.new("handler::client")

    Log4r::StderrOutputter.new("stderr", :level => Log4r::WARN)
    Log4r::StdoutOutputter.new("stdout", :level => params["verbose"].value ? Log4r::DEBUG : Log4r::INFO)

    Log4r::Logger["main"].add "stdout", "stderr"
    Log4r::Logger["handler"].add "stdout", "stderr"
  end
}
