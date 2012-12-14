require 'rubygems'
require 'faye'
require 'eventmachine'

b = false
EM.run {
  client = Faye::Client.new('http://localhost:9292/faye')

  client.subscribe('/retrieve') do |message|
    puts "Bayeux server : " + message.inspect
    EM.stop_event_loop
  end
}
  
puts "process has ended"