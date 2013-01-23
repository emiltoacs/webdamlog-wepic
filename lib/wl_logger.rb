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

class WLEnginelogger < WLLogger
  def debug message
    super "WLEngine:#{message.strip}"
  end
  def info message
    super "#WLEngine::#{message.strip}"
  end
  def warn message
    super "WLEngine::#{message.strip}"
  end
  def fatal message
    super "WLEngine::#{message.strip}"
  end
end