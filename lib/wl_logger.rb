require 'logger'

class WLLogger < Logger
  def debug message
    super "#{ENV['USERNAME']}:#{message.strip}"
  end  
  def info message
    super "#{ENV['USERNAME']}:#{message.strip}"
  end
  def warn message
    super "#{ENV['USERNAME']}:#{message.strip}"
  end
  def fatal message
    super "#{ENV['USERNAME']}:#{message.strip}"
  end
end
