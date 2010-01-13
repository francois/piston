require "log4r"
require "active_support"
require "piston/version"
require "optparse"

module Piston
  class Cli
    def self.start(args=ARGV)
      options = {:lock => false, :force => false, :dry_run => false, :quiet => false, :verbose => 0}
      opts = OptionParser.new do |opts|
        opts.banner  = "Usage: piston COMMAND [options]"
        opts.version = Piston::VERSION::STRING

        # Many!!!
        opts.on("-r", "--revision REVISION", "Revision to operate on") do |r|
          options[:revision] = r.to_i
        end

        opts.on("--commit TREEISH", "Commit to operate on") do |c|
          options[:commit] = c
        end

        # Import
        opts.on("--repository-type TYPE", [:git, :svn], "Force selection of a repository handler (git or svn)") do |type|
          options[:repository_type] = type
        end

        # Import, Update and Switch
        opts.on("--lock", "Lock down the revision against mass-updates") do
          options[:lock] = true
        end

        opts.on("--show-updates", "Query the remote repository for out-of-dateness information") do
          options[:show_updates] = true
        end

        # All
        opts.on("--force", "Force the operation to go ahead") do
          options[:force] = true
        end

        opts.on("--dry-run", "Run but do not change anything") do
          options[:dry_run] = true
        end

        opts.on("-q", "--quiet", "Operate silently") do
          options[:quiet] = true
        end

        opts.on("-v", "--verbose [LEVEL]", ("0".."5").to_a, "Increase verbosity (default 0)") do |level|
          options[:verbose] = level.to_i || 1
        end
      end
      opts.parse!(args)

      if args.empty?
        puts opts.help
        exit 0
      end

      if options.has_key?(:revision) && options.has_key?(:commit) then
        raise ArgumentError, "Only one of --revision or --commit can be given.  Received both."
      end

      configure_logging(options)
      command = Piston::Commands.const_get(args.shift.camelize).new(options)
      command.start(*args)
    end

    def self.configure_logging(options)
      Log4r::Logger.root.level = Log4r::DEBUG

      case options[:verbose]
      when 0
        main_level = Log4r::INFO
        handler_level = Log4r::WARN
        client_level = Log4r::WARN
        client_out_level = Log4r::WARN
        stdout_level = Log4r::INFO
      when 1
        main_level = Log4r::DEBUG
        handler_level = Log4r::INFO
        client_level = Log4r::WARN
        client_out_level = Log4r::WARN
        stdout_level = Log4r::DEBUG
      when 2
        main_level = Log4r::DEBUG
        handler_level = Log4r::DEBUG
        client_level = Log4r::INFO
        client_out_level = Log4r::WARN
        stdout_level = Log4r::DEBUG
      when 3
        main_level = Log4r::DEBUG
        handler_level = Log4r::DEBUG
        client_level = Log4r::DEBUG
        client_out_level = Log4r::INFO
        stdout_level = Log4r::DEBUG
      when 4, 5
        main_level = Log4r::DEBUG
        handler_level = Log4r::DEBUG
        client_level = Log4r::DEBUG
        client_out_level = Log4r::DEBUG
        stdout_level = Log4r::DEBUG
      else
        raise ArgumentError, "Did not expect verbosity to be outside 0..5: #{options[:verbose]}"
      end

      Log4r::Logger.new("main", main_level)
      Log4r::Logger.new("handler", handler_level)
      Log4r::Logger.new("handler::client", client_level)
      Log4r::Logger.new("handler::client::out", client_out_level)

      Log4r::StdoutOutputter.new("stdout", :level => stdout_level)

      Log4r::Logger["main"].add "stdout"
      Log4r::Logger["handler"].add "stdout"
    end
  end
end

Piston::Cli.start
