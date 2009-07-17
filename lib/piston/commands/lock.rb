require "piston/commands/lock_unlock"

module Piston
  module Commands
    class Unlock < LockUnlock
      def start(*args)
        args.each do |arg|
          options[:wcdir] = arg
          run(false)
        end
      end
    end
  end
end
