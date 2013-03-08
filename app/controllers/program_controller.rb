class ProgramController < ApplicationController
  
  def index
    # #Do not load program if already in main memory
    
    # #TODO:This line assumes there is only one program. This assumption #should
    # be relaxed later.
    @program = Program.first
    @program = load_program(Conf.peer['peer']['program']['file_path']) if @program.nil?
    
    flash.now[:alert] = 'The program was not loaded properly.' unless @program
    
  end
  
  # Loads a webdamlog program specified by the given filepath.
  def load_program(file_path)
    
    # Load default program PeerProperties.config if missing
    name = File.basename file_path
    
    # Get the data attribute from the file.
    data = ""
    begin
      # Here we enter from Rails root directory
      file = File.open(Rails.root+file_path)
      while line = file.gets
        data += line+'\n'
      end
    rescue => error
      logger.warn error.inspect
      return nil
    end
    logger.info "Program Configuration:\n\t-#{name}\n\t-#{file_path}"

    # WLBUDinsert
    
    # This is the table in the database that is storing the program
    program = Program.new(:name=>name,:source=>file_path,:data=>data)
    return nil unless program.save
    program
  end # end load_program
  
end