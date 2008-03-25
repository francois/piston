module Piston
  class Revision
    include Enumerable

    class << self
      def logger
        @@logger ||= Log4r::Logger["handler"]
      end
    end

    attr_reader :repository, :revision

    def initialize(repository, revision)
      @repository, @revision = repository, revision
    end

    def name
      @revision
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

    # Yields each file of this revision in turn to our callers.
    def each
    end

    # Copies +relpath+ (relative to ourselves) to +abspath+ (an absolute path).
    def copy_to(relpath, abspath)
    end
  end
end
