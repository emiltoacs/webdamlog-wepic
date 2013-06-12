require 'logger'

module WLLogger
  
  def self.logger
    @logger = WLLogger.new STDOUT unless @logger
    @logger
  end
  
  class WLLogger < Logger
    def initialize args
      super args
      if ENV['USERNAME']
        @prefix = ENV['USERNAME']+":"
      else
        @prefix = ""
      end
    end
    def debug message
      super "#{@prefix}#{message.strip}"
    end  
    def info message
      super "#{@prefix}#{message.strip}"
    end
    def warn message
      super "#{@prefix}#{message.strip}"
    end
    def fatal message
      super "#{@prefix}#{message.strip}"
    end
  end

  class WLEngineLogger < WLLogger
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
end
