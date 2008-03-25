require "piston/revision"

module Piston
  class Repository
    class UnhandledUrl < RuntimeError; end

    class << self
      def logger
        @@logger ||= Log4r::Logger["handler"]
      end

      def guess(url)
        logger.info {"Guessing the repository type of #{url.inspect}"}

        handler = handlers.detect do |handler|
          logger.debug {"Asking #{handler}"}
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
      logger.info {"Targeting #{self} at #{revision.inspect}"}
      Piston::Revision.new(self, revision)
    end

    def to_s
      "Piston::Repository(#{@url})"
    end
  end
end
