require 'wl_logger'
require 'webdamlog/wlbud'

# There is the set of function used to manage the webdamlog engine from the
# wepic app
#
module WebdamlogEngine
  
  # TODO add action on shutdown for the wlengine such as erase program file if saved in db and clean rule dir if needed
  #
  class WebdamlogEngine

    STR0 = <<EOF
peer p0=localhost:11110;
collection ext persistent bootstrap@p0(atom1*);
fact bootstrap@p0(1);
fact bootstrap@p0(2);
fact bootstrap@p0(3);
fact bootstrap@p0(4);
end
EOF

    def initialize
      #Create a subclass of WL
      klass = Class.new(WLBud::WL)
      # TODO find a good name for the sub class, it should be uniq
      wlport = properties['peer']['wdl_engine_port']
      self.class.class_eval "WLEngineOf#{ENV['USERNAME']}On#{wlport} = klass"
      peer_name = "peername_#{ENV['USERNAME']}on#{WLPORT}"
      # TODO find a good place to put the program file
      program_file_dir = File.expand_path('../../tmp/rule_dir', __FILE__)
      unless (File::directory?(program_file_dir))
        Dir.mkdir(program_file_dir)
      end
      program_file = File.join(program_file_dir,"programfile_of_#{ENV['USERNAME']}on#{WLPORT}")
      dir_rule = program_file_dir      
      File.open(program_file, 'w'){ |file| file.write STR0 }
      @webdamlog = nil
      eval("@webdamlog = ClassWL#{ENV['USERNAME']}on#{WLPORT}.new(peer_name,program_file,{:port => #{WLPORT}, :dir_rule => dir_rule})")
      @wlenginelogger = WLLogger::WLEngineLogger.new(STDOUT)
      msg = "peer_name = #{peer_name} program_file = #{program_file} dir_rule = #{dir_rule}"
      if @webdamlog.nil?
        @wlenginelogger.fatal("creation of the webdamlog engine instance has failed:\n#{msg}")
      else
        @wlenginelogger.info("new instance of webdamlog engine created:\n#{msg}")
      end
      #@webdamlog.run_bg
    end    
  end  
end
