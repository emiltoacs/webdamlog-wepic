require 'wl_tool'
# FIXME I wrote lots of code used for user input checking in this controller,
# move that to client side or model
# http://guides.rubyonrails.org/active_record_validations_callbacks.html
#
class QueryController < ApplicationController
  include WLDatabase
  
  def index
    #Fetches relation from schema
    @relation_classes = database(Conf.env['USERNAME']).relation_classes
    @described_rules = DescribedRule.where(:role => 'rule')
    @described_rule = DescribedRule.new
    respond_to do |format|
      format.json {render :json => @described_rules}
      format.html
    end
  end
  
  #Insert a tuple in the instance database
  def insert
    puts "Parameters #{params}"
    if params[:relation][:name].nil? || params[:relation][:name].empty?
      respond_to do |format|
        format.html {redirect_to '/query', :notice => "No relations were selected"}
      end
    else
      @relation_classes = database(Conf.env['USERNAME']).relation_classes
      rel_name = params[:relation][:name] #All relation names in the relation classes should be capitalized
      # values = params[:values].split(";").map! { |i| WLTool::sanitize!(i) }
      # values_hash = Hash.new
    
      # FIXME This temporary code takes the values inserted and matches them in
      # order with the corresponding class schema. Ideally we would want to use
      # the params variable to match the items directly.This requires calls to
      # jquery to dynamically send the corresponding rows once a relation is
      # selected.
      # @relation_classes[rel_name].schema.keys.each_index do |i|
        # values_hash[@relation_classes[rel_name].schema.keys[i]]=values[i] 
      # end
    
      # WLBUDinsert
      tuple = @relation_classes[rel_name].new(params[:values])
      respond_to do |format|
        if tuple.save
          format.html { redirect_to :query}
          format.json { head :no_content }
        else
          format.html {redirect_to '/query', :alert => "Unable to insert fact : reason=#{tuple.error.messages.inspect}"}
          format.json {head :no_content}
        end
      end
    end
  end
    
  # Creates a new relation and adds it to the session database.
  def create
    schema = Hash.new
    rel_name = WLTool::sanitize(params[:relation_name]).capitalize
    # TODO jQuery to display nice form
    col_names = params[:column_names].split(";").map! { |i| WLTool::sanitize!(i) }
    col_names.each do |name|
      schema[name]='text'
    end
    database(Conf.env['USERNAME']).create_model(rel_name,schema)
    @relation_classes = database(Conf.env['USERNAME']).relation_classes
    respond_to do |format|
      format.html { redirect_to '/query', :notice => "Relation classes: #{@relation_classes.inspect}" }
      format.json { head :no_content }
    end    
  end # create
  
  def add_described_rule
    # saved , response = ContentHelper::add_to_described_rules(params[:rule],params[:description],params[:role],:skip_ar_wrapper)
    rule = params[:rule]
    drule = DescribedRule.new(:wdlrule =>rule,:description => params[:description], :role=> params[:role])
    saved = drule.save
    err = drule.errors.messages
    id = drule.id
    if saved
      #id = response
      ContentHelper.describedRules << rule
      respond_to do |format|
        format.json {render :json => {:saved => true, :id => id}.to_json }
        format.html {redirect_to :query }
      end
    else
      logger.debug "Unable to save to describe rule : #{err}"
      respond_to do |format|
        format.json {render :json => {:saved => false, :errors => err}.to_json }
        format.html {redirect_to :query, :alert => err }
      end
    end
  end
  
  #Do not allow removing rules for now.
  def remove_described_rule
    # described_rule = DescribedRule.find(params[:id])
    # described_rule.destroy
    # respond_to do |format|
      # format.json {render :json => {:saved => true}.to_json }
    # end
  end
  
  def relation
    @relation_classes = database(Conf.env['USERNAME']).relation_classes unless @relation_classes
    relation_name = params[:relation]
    @relation_classes.keys.each {|rel| if rel.downcase==relation_name.downcase then relation_name = rel end} unless @relation_classes.include?(relation_name)
    columns = @relation_classes[relation_name].column_names.select{|col| !['id','created_at','updated_at','picture_id','image_file_name','image_file_size','image_content_type','image_updated_at','image_file','image_small_file','image_thumb_file'].include?(col)}
    content = @relation_classes[relation_name].all.map {|record| record.attributes.except('id','created_at','updated_at','picture_id','image_file_name','image_file_size','image_content_type','image_updated_at')}
    #We remove the id, created_at and updated_at fields which are not part of webdamlog, if they are present. 
    respond_to do |format|
      format.json {render :json => [:sucess => true, :columns=>columns,:content=>content].to_json}
    end
  end

end # QueryController
