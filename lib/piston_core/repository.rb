require "piston_core/revision"

module PistonCore
  class Repository
    class UnhandledUrl < RuntimeError; end

    class << self
      def logger
        @@logger
      end

      def logger=(logger)
        @@logger = logger
        PistonCore::Revision.logger = @@logger
      end

      def guess(url)
        logger.debug {"Guessing the repository type of #{url.inspect}"}

        handler = handlers.detect do |handler|
          handler.understands_url?(url)
        end

        raise UnhandledUrl, "No internal handlers found for #{url.inspect}.  Do you want to help ?" if handler.nil?
        handler.new(url)
      end

      @@handlers = Array.new
      def add_handler(handler)
        @@handlers << handler
      end

      def handlers
        @@handlers
      end
      private :handlers
    end

    attr_reader :url

    def initialize(url)
      @url = url
    end

    def logger
      self.class.logger
    end

    def at(revision)
      logger.debug {"Targeting #{self} at #{revision.inspect}"}
      PistonCore::Revision.new(self, revision)
    end

    def to_s
      "PistonCore::Repository(#{@url})"
    end
  end
end
