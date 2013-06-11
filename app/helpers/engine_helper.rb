require 'wl_logger'
require 'wl_tool'
require 'webdamlog/wlbud'
require 'webdamlog/webdamlog_runner'
require 'fileutils'

# There is the set of function used to manage the webdamlog engine from the
# wepic app
#
# See the engine_initializer that define the constant used throughout the
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

    attr_reader :dir_rule, :port, :peername, :bootstrap_program, :rule_dir
        
    def initialize
      @enginelogger = WLLogger::WLEngineLogger.new(STDOUT)
      username = Conf.peer['peer']['username']
      #web_port = Integer(Conf.peer['peer']['web_port'])
      port = Network.find_port Conf.peer['peer']['ip'], :UDP
      unless port
        @enginelogger.fatal("unable to find a UDP port for the webdamlog engine")
        raise StandardError, "unable to find a UDP port for the webdamlog engine"
      end
      program_file = create_program_dir Conf.peer['peer']['program']['file_path']
      rule_dir = File.dirname program_file
      @engine = ::WLRunner.create(username, program_file, port, {:rule_dir => rule_dir})
      # peername in webdamlog
      @peername = @engine.peername
      # port on which webdamlog is listening
      @port = @engine.port
      # bootstrap program read by webdamlog to start
      @bootstrap_program = @engine.filename
      # rules created by webdamlog
      @rule_dir = @engine.rule_dir
      
      msg = "\tpeer_name = #{@peername}\n\tprogram_file = #{File.basename(@bootstrap_program)}\n\tdir_rule = #{@rule_dir}\n\ton port #{@port}"
      Conf.peer['peer']['wdl_engine_port'] = Integer(@port)
      
      if @engine.nil?
        @enginelogger.fatal("creation of the webdamlog engine instance has failed:\n#{msg}")
      else
        @enginelogger.debug("new instance of webdamlog engine created:\n#{msg}")
      end
    end # initialize

    def run
      @engine.run_bg
      @enginelogger.info("internal webdamlog engine start running listening on port #{@port}")
      @engine
    end

    private

    # Create the directory in which to put the program that must be writing into
    # files because of bud methods to parse bloom blocks.
    #
    # Return the absolute path to the program file created for bootstrap
    #
    def create_program_dir program_file
      program_file_dir = File.expand_path('../../../tmp/rule_dir', __FILE__)
      unless (File::directory?(program_file_dir))
        Dir.mkdir(program_file_dir)
      end
      username = Conf.peer['peer']['username']
      peer_program_dir = File.join(program_file_dir, username)
      unless (File::directory?(peer_program_dir))
        Dir.mkdir(peer_program_dir)
      end
      pg_file = File.join(peer_program_dir, File.basename(program_file))
      FileUtils.cp program_file, pg_file
      return pg_file
    end # create_program_dir
    
  end # Class EngineHelper


  module ActiveRecordWrapper

    

  end

end # Module EngineHelper
