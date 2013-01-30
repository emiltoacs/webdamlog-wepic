require 'yaml'
require 'lib/wl_logger'
class ProgramController < ApplicationController
  
  def index
    #Do not load program if already in main memory
    
    @program = Program.first
    @program = load_program(nil) if @program.nil?
    
    flash.now[:alert] = 'The program was not loaded properly.' unless @program
    
  end
  
  def load_program(filepath)
    WLLogger.logger.info "Loading default program" unless filepath
    filepath='config/properties.yml' unless filepath
    #Get properties file
    properties = YAML.load_file(filepath)
    #default values
    name = "Unknown"
    author = "Unknown"
    source = ""    
    
    #Initialize default program properties.
    name = properties['default_program']['name'] if properties['default_program']['name']
    author = properties['default_program']['author'] if properties['default_program']['author']
    source = properties['default_program']['source'] if properties['default_program']['source']
    
    filename = "#{name}"
    data = ""
    #Get the data attribute from the file.
    begin
    file = File.open(filename)
    while line = file.gets
      data += line+'\n'
    end
    rescue => error
      WLLogger.logger.warn error.inspect
      return nil
    end
    
    WLLogger.logger.info "Program Configuration"
    WLLogger.logger.info name
    WLLogger.logger.info author
    WLLogger.logger.info source
    
    #This is the table in the database that is storing the program
    program = Program.new(:name=>name,:author=>author,:source=>source,:data=>data)
    return nil unless program.save
    program
  end
end