require "piston/revision"

module Piston
  class Repository
    class << self
      def logger
        @@logger
      end

      def logger=(logger)
        @@logger = logger
        Piston::Revision.logger = @@logger
      end

      def guess(url)
        logger.debug {"Guessing the repository type of #{url.inspect}"}
        self.new(url)
      end
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
      Piston::Revision.new(self, revision)
    end

    def to_s
      "Piston::Repository(#{@url})"
    end
  end
end
