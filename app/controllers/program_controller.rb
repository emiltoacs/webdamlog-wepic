class ProgramController < ApplicationController
  include EngineHelper
  
  def index
    # #Do not load program if already in main memory
    
    # #TODO:This line assumes there is only one program. This assumption #should
    # be relaxed later.
    @program = WLENGINE.snapshot_collections
    @described_rules = DescribedRule.all
    
    flash.now[:alert] = 'The program was not loaded properly.' unless @program
    
  end
  
  # Loads a webdamlog program specified by the given filepath.
  # def load_program(file_path)
#     
    # # Load default program PeerProperties.config if missing
    # name = File.basename file_path
#     
    # # Get the data attribute from the file.
    # data = ""
    # begin
      # # Here we enter from Rails root directory
      # file = File.open(Rails.root+file_path)
      # while line = file.gets
        # data += line+'\n'
      # end
    # rescue => error
      # logger.warn error.inspect
      # return nil
    # end
    # logger.info "Program Configuration:\n\t-#{name}\n\t-#{file_path}"
# 
    # # WLBUDinsert
#     
    # # This is the table in the database that is storing the program
    # program = Program.new(:name=>name,:source=>file_path,:data=>data)
    # return nil unless program.save
    # program
  # end # end load_program
  
  def get
    @peers = WLENGINE.snapshot_peers
    @collections = WLENGINE.snapshot_collections
    @rules = WLENGINE.snapshot_rules
    respond_to do |format|
      format.json {render :json => {:peers => @peers , :collections => @collections, :rules => @rules}.to_json}
    end
  end
  
  def delegations
    @delegations = {}
    Delegation.where(:decision=>false).all.each {|delegation| @delegations[delegation.wdlrule_id]=delegation.wdlrule}
    respond_to do |format|
      format.json{render :json => {:has_new => true, :content => @delegations}}
    end
  end
  
  #Delegation tuple is removed if the rule was rejected.
  def reject
    tuple = Delegation.find(:first, :wdlrule_id => params[:id])
    if tuple.nil?
      respond_to do |format|
        format.json {render :json => {:success => false, :errors => {"tuple" => "no tuple for wdlrule_id : #{params[:id]}"}}}
      end      
    else
      delegation = tuple.first
      delegation.destroy
      respond_to do |format|
        format.json {render :json => {:success => true, :errors => {}}}
      end
    end
  end
  
  #Delegation is tagged as accepted if it is accepted.
  def accept
    tuple = Delegation.find(:first, :wdlrule_id => params[:id])
    if tuple.nil?
      respond_to do |format|
        format.json {render :json => {:success => false, :errors => {"tuple" => "no tuple for wdlrule_id : #{params[:id]}"}}}
      end      
    else
      delegation = tuple.first
      delegation.accepted = true
      if delegation.save
        respond_to do |format|
          format.json {render :json => {:success => true, :errors => {}}}
        end
      else
        respond_to do |format|
          format.json {render :json => {:success => false, :errors => delegation.errors.messages }}
        end
      end
    end
  end
end