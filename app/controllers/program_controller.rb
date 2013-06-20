class ProgramController < ApplicationController
  include EngineHelper
  
  def index  
  end
    
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
    Delegation.where(:accepted=>false).all.each {|delegation| @delegations[delegation.id]=delegation.wdlrule}
    respond_to do |format|
      format.json{render :json => {:has_new => true, :content => @delegations}}
    end
  end
  
  #Delegation tuple is removed if the rule was rejected.
  def reject
    tuple = Delegation.find(params[:id])
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
    tuple = Delegation.find(params[:id])
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