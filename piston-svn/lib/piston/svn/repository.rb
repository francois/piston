require "piston/repository"
require "piston/svn/client"
require "uri"

module Piston
  module Svn
    class Repository < Piston::Repository
      extend Piston::Svn::Client

      class << self
        def understands_url?(url)
          uri = URI.parse(url)
          case uri.scheme
          when "svn", /^svn\+/
            true
          when "http", "file"
            # Have to contact server to know
            result = svn(:info, url) rescue :failed
            result == :failed ? false : true
          else
          end
        end
      end

      def svn(*args)
        self.class.svn(*args)
      end

      def svnadmin(*args)
        self.class.svnadmin(*args)
      end

      def at(revision)
        rev = case
              when revision == :head
                "HEAD"
              when revision.to_i != 0
                revision.to_i
              else
                raise ArgumentError, "Invalid revision argument: #{revision.inspect}"
              end

        Piston::Svn::Revision.new(self, rev)
      end
    end
  end
end
