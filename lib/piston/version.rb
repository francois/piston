module Piston #:nodoc:
  module VERSION #:nodoc:
    def self.config
      @@version ||= YAML.load_file(File.dirname(__FILE__) + "/../../VERSION.yml")
    end

    def self.read_version
      "%s.%s.%s" % [config[:major], config[:minor], config[:patch]]
    end

    STRING = read_version
  end
end
