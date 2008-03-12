module Piston
  class Revision
    class << self
      def logger=(logger)
        @@logger = logger
      end

      def logger
        @@logger
      end
    end

    def initialize(repository, revision)
      @repository, @revision = repository, revision
    end

    def logger
      self.class.logger
    end

    def to_s
      "Piston::Revision(#{@repository.url}@#{@revision})"
    end
  end
end
