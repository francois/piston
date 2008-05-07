require "piston/commands/base"

module Piston
  module Commands
    class Lock < Piston::Commands::Base
      attr_reader :options

      def run(lock)
        working_copy = Piston::WorkingCopy.guess(options[:wcdir])
        
        raise Piston::WorkingCopy::NotWorkingCopy if !working_copy.exist? || !working_copy.pistonized?
        
        values = working_copy.recall
        values["lock"] = lock
        working_copy.remember(values, values["handler"])
        working_copy.finalize
      end
      
      protected
      # Copied from ActiveSupport
      def constantize(camel_cased_word)
        unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ camel_cased_word
          raise NameError, "#{camel_cased_word.inspect} is not a valid constant name!"
        end
      
        Object.module_eval("::#{$1}", __FILE__, __LINE__)
      end
    end
  end
end
