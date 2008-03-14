require "piston_core/revision"

module PistonCore
  class Repository
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
      PistonCore::Revision.new(self, revision)
    end

    def to_s
      "PistonCore::Repository(#{@url})"
    end
  end
end
