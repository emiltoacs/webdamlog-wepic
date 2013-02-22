require 'wl_logger'
require 'wl_tool'
require 'webdamlog/wlbud'

# There is the set of function used to manage the webdamlog engine from the
# wepic app
#
# See the engine_initializer that define the constant used thoughout the
# project to refere to this webdamlog engine.
#
module EngineHelper
  
  # TODO add action on shutdown for the wlengine such as erase program file if
  # saved in db and clean rule dir if needed
  #
  class EngineHelper
    include Singleton
    include WLTool

    attr_accessor :engine, :enginelogger
    
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
      username = Conf.peer['peer']['peername']
      root_port = Integer(Conf.peer['peer']['web_port'])
      wlport = Network.find_ports('localhost', 1, root_port+1)
      Conf.peer['peer']['wdl_engine_port'] = Integer(wlport)
      peer_name = "peername_#{username}on#{wlport}"

      # Dynamic class ClassWLEngineOf#{username}On#{wlport} subclass WLBud
      # Create a subclass of WL FIXME maybe useless to subclass here, since I
      # implement this as Singleton, no risk of border-effect in class varaible
      # 
      klass = create_class("ClassWLEngineOf#{username}On#{wlport}", WLBud::WL)
      
      # TODO find a good place to put the program file
      program_file_dir = File.expand_path('../../../tmp/rule_dir', __FILE__)
      unless (File::directory?(program_file_dir))
        Dir.mkdir(program_file_dir)
      end
      program_file = File.join(program_file_dir,"programfile_of_#{username}on#{wlport}")
      dir_rule = program_file_dir
      File.open(program_file, 'w'){ |file| file.write STR0 }
      @engine = klass.new(username, program_file, {:port => wlport, :dir_rule => dir_rule})
      @enginelogger = WLLogger::WLEngineLogger.new(STDOUT)
      msg = "peer_name = #{peer_name} program_file = #{program_file} dir_rule = #{dir_rule}"
      if @engine.nil?
        @enginelogger.fatal("creation of the webdamlog engine instance has failed:\n#{msg}")
      else
        @enginelogger.debug("new instance of webdamlog engine created:\n#{msg}")
      end
    end #initialize

    def run
      @engine.run_bg
      @enginelogger.info("internal webdamlog engine start running")
    end
    
  end
end
