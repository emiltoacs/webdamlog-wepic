class ProgramController < ApplicationController
  include EngineHelper
  
  def index  
  end
    
  def get
    @peers = WLENGINE.snapshot_peers
    @collections = WLENGINE.snapshot_collections
    @rules = WLENGINE.snapshot_rules
    @facts = Hash.new
    WLENGINE.snapshot_relname.each do |relname|
      @facts[relname] = WLENGINE.snapshot_facts(relname)
    end
    respond_to do |format|
      format.json {render :json => {:peers => @peers , :collections => @collections, :rules => @rules, :facts => @facts}.to_json}
    end
  end
  
  def delegations
    @delegations = {}
    Delegation.refresh_delegations
    Delegation.where(:accepted=>false).all.each {|delegation| @delegations[delegation.id]=delegation.wdlrule.gsub(/_at_/,'@')}
    respond_to do |format|
      format.json{render :json => {:has_new => true, :content => @delegations}}
    end
  end
  
  #Delegation tuple is removed if the rule was rejected.
  def reject
    delegation = Delegation.find(params[:id])
    if delegation.nil?
      respond_to do |format|
        format.json {render :json => {:success => false, :errors => {"tuple" => "no tuple for wdlrule_id : #{params[:id]}"}}}
      end      
    else
      delegation.destroy
      respond_to do |format|
        format.json {render :json => {:success => true, :errors => {}}}
      end
    end
  end
  
  #Delegation is tagged as accepted if it is accepted.
  def accept
    delegation = Delegation.find(params[:id])
    if delegation.nil?
      respond_to do |format|
        format.json {render :json => {:success => false, :errors => {"tuple" => "no tuple for wdlrule_id : #{params[:id]}"}}}
      end
    else
      delegation.accepted = true
      drule = DescribedRule.new(:wdlrule=>delegation.wdlrule.gsub(/_at_/,'@'),:description=>"Delegation from #{delegation.peername}",:role=>'unknown')
      if drule.save
        delegation.accepted = true
        if delegation.save
          respond_to do |format|
            format.json {render :json => {:success => true, :errors => {}}}
          end
        else
          respond_to do |format|
            format.json {render :json => {:success => false, :errors => delegation.errors.messages.merge(drule.errors.messages)}}
          end          
        end
      else
        respond_to do |format|
          format.json {render :json => {:success => false, :errors => drule.errors.messages}}
        end
      end
    end
  end
end