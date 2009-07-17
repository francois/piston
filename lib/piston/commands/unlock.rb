require "piston/commands/lock_unlock"

module Piston
  module Commands
    class Lock < LockUnlock
      def start(*args)
        args.each do |arg|
          options[:wcdir] = arg
          run(true)
        end
      end
    end
  end
end
