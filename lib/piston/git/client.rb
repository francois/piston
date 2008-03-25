require "singleton"

module Piston
  module Git
    class Client
      include Singleton

      class CommandError < RuntimeError; end
      class Failed < CommandError; end
      class BadCommand < CommandError; end

      def logger
        @logger ||= Log4r::Logger["handler::client"]
      end

      def git(*args)
        run_cmd :git, *args
      end

      private
      def run_cmd(executable, *args)
        args.collect! {|arg| arg =~ /\s|\*|\?|"|\n|\r/ ? %Q('#{arg}') : arg}
        args.collect! {|arg| arg ? arg : '""'}
        cmd = %Q|#{executable} #{args.join(' ')}|
        logger.debug {"> " + cmd}

        original_language = ENV["LANGUAGE"]
        begin
          ENV["LANGUAGE"] = "C"
          value = run_real(cmd)
          logger.debug {"< " + value} unless (value || "").strip.empty?
          return value
        ensure
          ENV["LANGUAGE"] = original_language
        end
      end

      begin
        raise LoadError, "Not implemented on Win32 machines" if RUBY_PLATFORM =~ /mswin32/

          begin
            require "rubygems"
          rescue LoadError
            # NOP -- attempt to load without Rubygems
          end

        require "open4"

        def run_real(cmd)
          begin
            pid, stdin, stdout, stderr = Open4::popen4(cmd)
            _, cmdstatus = Process.waitpid2(pid)
            return stdout.read if cmd =~ /status/ && cmdstatus.exitstatus == 1
            raise CommandError, "#{cmd.inspect} exited with status: #{cmdstatus.exitstatus}\n#{stderr.read}" unless cmdstatus.success?
            return stdout.read
          rescue Errno::ENOENT
            raise BadCommand, cmd.inspect
          end
        end

      rescue LoadError
        # On platforms where open4 is unavailable, we fallback to running using
        # the backtick method of Kernel.
        def run_real(cmd)
          out = `#{cmd}`
          raise BadCommand, cmd.inspect if $?.exitstatus == 127
          raise Failed, "#{cmd.inspect} exited with status: #{$?.exitstatus}" unless $?.success?
          out
        end
      end
    end
  end
end
