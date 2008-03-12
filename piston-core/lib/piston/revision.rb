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

    # Retrieve a copy of this repository into +dir+.
    def checkout_to(dir)
      logger.debug {"Checking out #{@repository}@#{@revision} into #{dir}"}
    end

    # What values does this revision want to remember for the future ?
    def remember_values
      logger.debug {"Generating remember values"}
      {}
    end
  end
end
