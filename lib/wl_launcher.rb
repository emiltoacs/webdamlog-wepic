# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygems'
require 'socket'
require 'timeout'
require 'set'
require 'pty'
require 'lib/bayeux'

module WLLauncher
  
  def wait_for_acknowledgment(server,port)
    begin
      Timeout::timeout(5) do
        begin
          client = server.accept
          client.gets
          client.close
          server.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          puts "Connection Error..."
          return false
        end        
      end
    rescue Timeout::Error
      puts "Time out..."
      return false
    end
  end
  
  #This method is not supposed to be used by webdamlog instance
  def start_peer(name,ext_name,manager_port,ext_port)
    if name=='MANAGER'
      thread = Thread.new do
        start_server(ext_name,manager_port,ext_port) if !ext_name.nil?
      end
      server = TCPServer.new(manager_port.to_i+1)
      b = wait_for_acknowledgment(server,ext_port)
      EM.run do
        client = Faye::Client.new('http://localhost:9292/faye')
        client.publish('/redirect', 'text' => "Port #{ext_port} is ready")
        EM.stop_event_loop
      end
      return b
    end
    false
  end  
  
  #This method is not supposed to be used by the manager, whose environment
  #variable MANAGER_PORT should be undefined (or nil).
  def send_acknowledgment(name,manager_port,port)
    if name!='MANAGER'
      socket = TCPSocket.open('localhost',manager_port.to_i + 1)
      socket.puts "Port #{port} ready"
      socket.close      
    end
  end
  
  def start_server(username,manager_port,port,server_type=:thin)
    cmd =  "rails server -p #{port} -u #{username}"
    begin
      PTY.spawn(cmd) do |stdin,stdout,pid|
        begin
          stdin.each do |line|
            puts line
            case server_type
            when :webrick
              if line.include?("pid=") && line.include?("port=")
                puts "Server is ready!"
                send_acknowledgment(username,manager_port,port)
                return
              end
            when :thin
              if line.include?("Listening on") && line.include?(", CTRL+C to stop")
                puts "Server is ready!"
                send_acknowledgment(username,manager_port,port)
                return
              end
            end
          end
        rescue Errno::EIO
          puts "Server is shutdown. No longer listening to server output EIO"
        rescue Errno::ECONNREFUSED
          puts "Server is shutdown. No longer listening to server output ECONN"
        end
      end
    rescue PTY::ChildExited
      puts "Child process exited!"
    end
  end
  
  #This method kills the wl server if it located on the same machine only.
  def exit_server(port,type=:rails)
    pids = Set.new
    case type
    when :rails
      `ps -ef | grep rails`.split("\n").each_with_index do |line,i|
        line_tokens = line.split(" ")
        pids.add(line_tokens[1]) if line_tokens.include?(port.inspect)
      end
    when :faye
      `ps -ef | grep rackup`.split("\n").each_with_index do |line,i|
        line_tokens = line.split(" ")
        pids.add(line_tokens[1]) if line_tokens.include?(port.inspect)
      end      
    end
    pids.each do |pid|
      system "kill -9 #{pid}"
      puts "Process #{pid} killed"
    end
    pids.size
  end
  
  def port_open?(ip, port)
    begin
      Timeout::timeout(1) do
        begin
          s = TCPSocket.new(ip, port)
          s.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end
      end
    rescue Timeout::Error
    end

    return false
  end  
end