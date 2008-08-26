require File.expand_path("#{File.dirname(__FILE__)}/../test_helper")

class TestImport < Piston::TestCase
  def setup
    super
    @wc = stub_everything("working_copy")
    @cmd = Piston::Commands::Import.new
  end
end
