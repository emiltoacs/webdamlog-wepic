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
  end
  
  #Insert a tuple in the instance database
  def insert
    if params[:relation][:name].nil?
      respond_to do |format|
        format.html {redirect_to '/query', :notice => "No relation was selected"}
      end
    else
      @relation_classes = database(Conf.env['USERNAME']).relation_classes
      rel_name = params[:relation][:name].map! { |i| WLTool::sanitize!(i) }
      values = params[:values].split(";").map! { |i| WLTool::sanitize!(i) }
      values_hash = Hash.new
      # FIXME This temporary code takes the values inserted and matches them in
      # order with the corresponding class schema. Ideally we would want to use
      # the params variable to match the items directly.This requires calls to
      # jquery to dynamically send the corresponding rows once a relation is
      # selected.
      @relation_classes[rel_name].schema.keys.each_index do |i|
        values_hash[@relation_classes[rel_name].schema.keys[i]]=values[i] 
      end

      # WLBUDinsert
      
      respond_to do |format|
        if @relation_classes[rel_name].insert(values_hash)
          format.html { redirect_to '/query', :notice => "#{rel_name} : #{values_hash.inspect}"}
          format.json { head :no_content }
        else
          format.html {redirect_to '/query', :notice => "insert did not happen properly"}
          format.json {head :no_content}
        end
      end
    end
  end
    
  # Creates a new relation and adds it to the session database.
  def create
    schema = Hash.new
    rel_name = WLTool::sanitize(params[:relation_name])
    # TODO jQuery to display nice form
    col_names = params[:column_names].split(";").map! { |i| WLTool::sanitize!(i) }
    col_types = params[:column_types].split(";").map! { |i| WLTool::sanitize!(i) }
    # field must be a valid type: http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-column
    type = ['string', 'text', 'integer', 'float', 'decimal', 'datetime', 'timestamp', 'time', 'date', 'binary', 'boolean']
    err_message = ""
    require 'debugger' ; debugger
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
    # WLBUDinsert
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

end # QueryController
