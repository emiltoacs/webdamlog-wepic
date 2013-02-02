class ProgramController < ApplicationController
  
  def index
    #Do not load program if already in main memory
    
    #TODO:This line assumes there is only one program. This assumption
    #should be relaxed later.
    @program = Program.first
    @program = load_program if @program.nil?
    
    flash.now[:alert] = 'The program was not loaded properly.' unless @program
    
  end
  
  #Loads a webdamlog program specified by the given filepath.
  def load_program(filepath="",name=nil,author=nil)
    
    #Load default program properties if missing
    name ||= properties['peer']['program']['name'] if properties['peer']['program']['name']
    author ||= properties['peer']['program']['author'] if properties['peer']['program']['author']
    filepath = properties['peer']['program']['source'] if properties['peer']['program']['source']
    
    #Get the data attribute from the file.
    data = ""
    begin
    file = File.open(filepath)
    while line = file.gets
      data += line+'\n'
    end
    rescue => error
      logger.warn error.inspect
      return nil
    end
    logger.info "Program Configuration:\n\t-#{name}\n\t-#{author}\n\t-#{filepath}"
    
    #This is the table in the database that is storing the program
    program = Program.new(:name=>name,:author=>author,:source=>filepath,:data=>data)
    return nil unless program.save
    program
  end
end