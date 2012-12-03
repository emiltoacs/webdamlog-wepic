# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'test/unit'

class DestroyRails < Test::Unit::TestCase
  def test_destroy_background_processes
    pids = Array.new
    `ps -ef | grep rails`.split("\n").each_with_index do |line,i|
       pids[i]=line.split(" ")[1]
    end
    pids.each_with_index do |pid,i|
      system "kill -9 #{pid}"
      puts "#{i} : #{pid}, killed"
    end
    assert_equal(true,`ps -ef | grep rails`.split("\n").empty?)
  end
end
