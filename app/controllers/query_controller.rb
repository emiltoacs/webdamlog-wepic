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
    @described_queries = DescribedRule.where(:role=>'query')
    @described_updates = DescribedRule.where(:role=>'update')
    @described_query = DescribedRule.new
    @described_udpate = DescribedRule.new
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
    col_types = params[:column_types].split(";").map! { |i| WLTool::sanitize!(i) }
    # field must be a valid type: http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-column
    type = ['string', 'text', 'integer', 'float', 'decimal', 'datetime', 'timestamp', 'time', 'date', 'binary', 'boolean']
    err_message = ""
    if col_names.size == col_types.size
      col_names.each_index do |i|
        if type.include? col_types[i]
          schema[col_names[i]] = col_types[i]
        else
          err_message = "type not conform, found #{col_names[i]} but expected one of #{type.inspect}"
        end
      end
    else
      err_message = "number of type and columns should be the same"
    end
    
    begin
      if err_message.empty?
        database(Conf.env['USERNAME']).create_model(rel_name,schema)
        @relation_classes = database(Conf.env['USERNAME']).relation_classes
      else
        raise err_message
      end
    rescue => error
      respond_to do |format|
        format.html { redirect_to '/query', :notice => "Error: #{error.to_s} : #{error.message}" }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to '/query', :notice => "Relation classes: #{@relation_classes.inspect}" }
        format.json { head :no_content }
      end
    end
  end # create
  
  def add_described_rule
    described_rule = DescribedRule.new(:rule=>params[:rule],:description=>params[:description],:role=>params[:role])
    if described_rule.save 
      respond_to do |format|
        format.json {render :json => {:saved => true, :id => described_rule.id}.to_json }
        format.html {redirect_to :query }
      end
    else
      respond_to do |format|
        format.json {render :json => {:saved => false, :errors => save.errors.messages}.to_json }
        format.html {redirect_to :query, :alert => picture.errors.messages.inspect }
      end
    end
  end
  
  def remove_described_rule
    described_rule = DescribedRule.find(params[:id])
    described_rule.destroy
    respond_to do |format|
      format.json {render :json => {:saved => true}.to_json }
    end    
  end
  
  def relation
    @relation_classes = database(Conf.env['USERNAME']).relation_classes unless @relation_classes
    relation_name = params[:relation]
    columns = @relation_classes[relation_name].column_names.select{|col| !['id','created_at','updated_at','picture_id','image_file_name','image_file_size','image_content_type','image_updated_at','image_file','image_small_file','image_thumb_file'].include?(col)}
    content = @relation_classes[relation_name].all.map {|record| record.attributes.except('id','created_at','updated_at','picture_id','image_file_name','image_file_size','image_content_type','image_updated_at')}
    #We remove the id, created_at and updated_at fields which are not part of webdamlog, if they are present. 
    respond_to do |format|
      format.json {render :json => [:columns=>columns,:content=>content].to_json}
    end
  end

end # QueryController
