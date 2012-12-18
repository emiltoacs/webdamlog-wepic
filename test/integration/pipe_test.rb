# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'rubygems'
require 'test/unit'
require 'app/helpers/wl_launcher'
require 'childprocess'

class PipeTest < Test::Unit::TestCase
  include WLLauncher
  def test_pipe
    require 'pty'
    @line = ""
    #cmd = "ruby test/integration/example_pipe.rb"
    cmd = "script/rails server manager"
    begin
      PTY.spawn(cmd) do |stdin,stdout,pid|
        begin
          stdin.each do |line|
            if line.include?("pid=")
              print line
              @line = line
              break
            end
          end
        rescue Errno::EIO
        end   
      end
    rescue PTY::ChildExited
      puts "Child process exited!"
    end
    assert_equal(true,@line.include?("port="))
  end
end
