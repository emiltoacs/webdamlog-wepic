require 'test_helper'

class WlProgramTest < Test::Unit::TestCase

  # Test the bootstrap program for peers
  def test_bootstrap_peer_program
    pg_file = File.expand_path('./app/assets/wlprogram/bootstrap_program.wl')
    begin
      assert_nothing_raised do
        program = WLBud::WLProgram.new(
          'the_peername',
          pg_file,
          'localhost',
          '11111',
          {:debug => true} )
      end
    end
  end

  # Test the bootstrap program for the sigmod peer
  def test_bootstrap_scenario_program
    pg_file = File.expand_path('./app/assets/wlprogram/bootstrap_sigmod.wl')
    begin
      assert_nothing_raised do
        program = WLBud::WLProgram.new(
          'the_peername',
          pg_file,
          'localhost',
          '11111',
          {:debug => true})
      end
    end
  end
end
