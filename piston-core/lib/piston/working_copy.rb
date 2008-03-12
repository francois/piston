module Piston
  class WorkingCopy
    class << self
      def logger=(logger)
        @@logger = logger
      end

      def logger
        @@logger
      end

      def guess(path)
        logger.debug {"Guessing the working copy type of #{path.inspect}"}
        self.new(path)
      end
    end

    attr_reader :path

    def initialize(path)
      @path = Pathname.new(path)
      logger.debug {"Initialized on #{@path}"}
    end

    def logger
      self.class.logger
    end

    def to_s
      "Piston::WorkingCopy(#{@path})"
    end
  end
end

