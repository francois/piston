require "yaml"

module Piston
  module Svn
    class WorkingCopy < Piston::WorkingCopy
      extend Piston::Svn::Client

      # Register ourselves as a handler for working copies
      Piston::WorkingCopy.add_handler self

      class << self
        def understands_dir?(dir)
          result = svn(:info, dir) rescue :failed
          result == :failed ? false : true
        end
      end

      def svn(*args)
        self.class.svn(*args)
      end

      def svnadmin(*args)
        self.class.svnadmin(*args)
      end

      def exist?
        result = svn(:info, path) rescue :failed
        logger.debug {"result: #{result.inspect}"}
        return false if result == :failed
        return false if result.nil? || result.chomp.strip.empty?
        return true if YAML.load(result).has_key?("Path")
      end

      def create
        svn(:mkdir, path)
      end

      def after_remember(path)
        info = svn(:info, path)
        return unless info =~ /\(not a versioned resource\)/i
        svn(:add, path)
      end

      def recall(keys)
        hash = Hash.new
        keys.each do |k|
          hash[k] = svn(:propget, k, path)
        end

        hash
      end

      def finalize
        targets = []
        Dir[path + "*"].each do |item|
          svn(:add, item)
        end
      end
    end
  end
end
