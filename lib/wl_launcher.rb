# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'socket'
require 'timeout'
require 'set'

module WLLauncher
  def start_server(port)
    pid = fork do
      exec "/bin/bash -l -c \"rails server -p #{port} -b 0.0.0.0\""
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