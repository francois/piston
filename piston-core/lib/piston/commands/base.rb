module Piston
  module Commands
    class Base
      class << self
        def logger=(logger)
          @@logger = logger
        end

        def logger
          @@logger
        end
      end

      attr_reader :options

      def initialize(options={})
        @options = options
        debug {"#{self.class.name} with options #{options.inspect}"}
      end

      def verbose
        @options[:verbose]
      end

      def force
        @options[:force]
      end

      def quiet
        @options[:quiet]
      end

      def logger
        self.class.logger
      end

      def debug(msg=nil)
        logger.debug { msg || yield }
      end

      def info(msg=nil)
        logger.info { msg || yield }
      end

      def warn(msg=nil)
        logger.warn { msg || yield }
      end

      def error(msg=nil)
        logger.error { msg || yield }
      end

      def fatal(msg=nil)
        logger.fatal { msg || yield }
      end
    end
  end
end
