require 'rubygems'
require 'faye'
require 'eventmachine'
require 'set'

def exit_server (port)
  pids = Set.new
  rackups = `ps -ef | grep rackup`
  rackups.split("\n").each_with_index do |line,i|
    line_tokens = line.split(" ")
    pids.add(line_tokens[1])
  end
  pids.each do |pid|
    system "kill -9 #{pid}"
    puts "Process #{pid} killed"
  end
  pids.size
end

t1 = Thread.new do
  system('rackup faye.ru -s thin -E production')
end

t2 = Thread.new do
  system('ruby test/integration/bayeux_test_server.rb')
end

def at_exit
  exit_server(9292)
  puts "Bye!"
  exit
end

t3 = Thread.new do
  while (true) do
    puts "Please enter something : "
    line = gets
    at_exit if line.include?('exit')
    EM.run do
      client = Faye::Client.new('http://localhost:9292/faye')
      client.publish('/retrieve', 'text' => line)
      puts "sending : " + line
      EM.stop_event_loop
    end 
  end
end

t1.join
t2.join
t3.join