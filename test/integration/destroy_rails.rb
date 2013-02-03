# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'test/unit'

#XXX Warning : Running this test will kill all rails instances! Even non-webdamsystem ones!
#For destroying a particular instance, please use the library method end_peer(port).
class DestroyRails < Test::Unit::TestCase
  def destroy_background_processes_test
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
  def destroy_faye_test
    pids = Array.new
    `ps -ef | grep rackup`.split("\n").each_with_index do |line,i|
       pids[i]=line.split(" ")[1]
    end
    pids.each_with_index do |pid,i|
      system "kill -9 #{pid}"
      puts "#{i} : #{pid}, killed"
    end
    assert_equal(true,`ps -ef | grep rackup`.split("\n").empty?)    
  end
end
