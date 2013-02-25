require 'wl_logger'
require 'wl_tool'
require 'webdamlog/wlbud'
require 'fileutils'

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
        
    def initialize
      @enginelogger = WLLogger::WLEngineLogger.new(STDOUT)
      username = Conf.peer['peer']['username']
      #web_port = Integer(Conf.peer['peer']['web_port'])
      @port = Network.find_port Conf.peer['peer']['ip'], :UDP
      unless @port
        @enginelogger.fatal("unable to find a UDP port for the webdamlog engine")
        raise StandardError, "unable to find a UDP port for the webdamlog engine"
      end
      Conf.peer['peer']['wdl_engine_port'] = Integer(@port)
      @peer_name = "peername_#{username}on#{@port}"

      # Dynamic class ClassWLEngineOf#{username}On#{@port} subclass WLBud
      # Create a subclass of WL FIXME maybe useless to subclass here, since I
      # implement this as Singleton, no risk of border-effect in class varaible
      #
      klass = create_class("ClassWLEngineOf#{username}On#{@port}", WLBud::WL)

      program_file = create_program_dir Conf.peer['peer']['program']['file_path']
      dir_rule = File.dirname program_file
      @engine = klass.new(username, program_file, {:port => @port, :dir_rule => dir_rule})
      
      msg = "peer_name = #{@peer_name} program_file = #{program_file} dir_rule = #{dir_rule} on port #{@port}"
      if @engine.nil?
        @enginelogger.fatal("creation of the webdamlog engine instance has failed:\n#{msg}")
      else
        @enginelogger.debug("new instance of webdamlog engine created:\n#{msg}")
      end
    end # initialize

    def run
      @engine.run_bg
      @enginelogger.info("internal webdamlog engine start running listeining on port #{@port}")
    end

    private

    # Create the directory in which to put the program that must be writing into
    # files because of bud methods to parse bloom blocks.
    #
    # Return the absolute path to the program file
    #
    def create_program_dir program_file
      program_file_dir = File.expand_path('../../../tmp/rule_dir', __FILE__)
      unless (File::directory?(program_file_dir))
        Dir.mkdir(program_file_dir)
      end
      peer_program_dir = File.join(program_file_dir, @peer_name)
      unless (File::directory?(peer_program_dir))
        Dir.mkdir(peer_program_dir)
      end
      # TODO write content of the file instead of filename
      pg_file = File.join(peer_program_dir, File.basename(program_file))
      FileUtils.cp program_file, pg_file
      return pg_file
    end
    
  end
end
