require 'wl_logger'
require 'wl_tool'
require 'webdamlog/wlbud'

# There is the set of function used to manage the webdamlog engine from the
# wepic app
#
module WebdamlogEngine  
  
  # TODO add action on shutdown for the wlengine such as erase program file if
  # saved in db and clean rule dir if needed
  #
  class WebdamlogEngine
    include WLTool

    :engine
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
      
      username = Conf.env['USERNAME']
      root_port = Integer(Conf.env['PORT'])
      wlport = Network.find_ports('localhost', 1, root_port+1)
      peer_name = "peername_#{username}on#{wlport}"

      # Dynamic class ClassWLEngineOf#{username}On#{wlport} subclass WLBud
      # Create a subclass of WL
      # TODO find a good name for the sub class, it should be uniq maybe use ccreate class in WLTool
#      klass = Class.new(WLBud::WL)
#      self.class.class_eval "ClassWLEngineOf#{username}On#{wlport} = klass"
      klass = create_class("ClassWLEngineOf#{username}On#{wlport}",WLBud::WL)
      
      # TODO find a good place to put the program file
      program_file_dir = File.expand_path('../../../tmp/rule_dir', __FILE__)
      unless (File::directory?(program_file_dir))
        Dir.mkdir(program_file_dir)
      end
      program_file = File.join(program_file_dir,"programfile_of_#{username}on#{wlport}")
      dir_rule = program_file_dir
      File.open(program_file, 'w'){ |file| file.write STR0 }
      #eval("@engine = ClassWLEngineOf#{username}On#{wlport}.new(username, program_file,{:port => #{wlport}, :dir_rule => dir_rule})")
      @engine = klass.new(username, program_file,{:port => wlport, :dir_rule => dir_rule})
      @wlenginelogger = WLLogger::WLEngineLogger.new(STDOUT)
      msg = "peer_name = #{peer_name} program_file = #{program_file} dir_rule = #{dir_rule}"
      if @engine.nil?
        @wlenginelogger.fatal("creation of the webdamlog engine instance has failed:\n#{msg}")
      else
        @wlenginelogger.info("new instance of webdamlog engine created:\n#{msg}")
      end
      require 'debugger' ; debugger
      @engine.run_bg
    end
  end
end
