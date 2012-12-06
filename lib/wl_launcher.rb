# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'socket'
require 'timeout'
require 'set'

module WLLauncher
  
  def wait_for_acknowledgment(server,port)
    begin
      Timeout::timeout(20) do
        begin
          client = server.accept
          puts client.gets          
          client.close
          server.close
          return true
        rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
          return false
        end        
      end
    rescue Timeout::Error
      return false
    end    
  end
  
  #This method is not supposed to be used by the manager, whose environment
  #variable MANAGER_PORT should be undefined (or nil).
  def send_acknowledgment(name,manager_port,port)
    if name!='MANAGER'
      socket = TCPSocket.open('localhost',manager_port)
      socket.puts "Port #{port} ready"
      socket.close      
    end
  end
  
  #This method is not supposed to be used by webdamlog instance
  def start_peer(name,username,manager_port,port)
    if name=='MANAGER'
      puts "Starting server"
      start_server(username,port) if !username.nil?
      server = TCPServer.new(manager_port)
      thread = Thread.new do
        wait_for_acknowledgment(server,port)
      end
      return thread
    end
    nil
  end
  
  def start_server(username,port)
    pid = fork do
      exec "/bin/bash -l -c \"rails server -p #{port} #{username}\""
    end
    Process.detach(pid)
  end
  
  #This method kills the wl server if it located on the same machine only.
  def exit_server(port)
    pids = Set.new
    `ps -ef | grep rails`.split("\n").each_with_index do |line,i|
      line_tokens = line.split(" ")
      pids.add(line_tokens[1]) if line_tokens.include?(port.inspect)
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