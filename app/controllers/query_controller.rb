class QueryController < ApplicationController
  include Database
  
  def index
    #Fetches relation from schema
    @relation_classes = database(ENV['USERNAME']).relation_classes
  end
  
  #Insert a tuple in the instance database
  def insert
    if params[:relation][:name].nil?
      respond_to do |format|
        format.html {redirect_to '/query', :notice => "No relation was selected"}
      end
    else
      @relation_classes = database(ENV['USERNAME']).relation_classes
      rel_name = params[:relation][:name]
      values = params[:values].split(";")
      values_hash = Hash.new
      #FIXME This temporary code takes the values inserted and matches them in order with
      #the corresponding class schema. Ideally we would want to use the params variable
      #to match the items directly.This requires calls to jquery to dynamically send
      #the corresponding rows once a relation is selected.
      @relation_classes[rel_name].schema.keys.each_index do |i|
        values_hash[@relation_classes[rel_name].schema.keys[i]]=values[i] 
      end
      # WLBUDinsert 
      respond_to do |format|
        @relation_classes[rel_name].open_connection
        if @relation_classes[rel_name].insert(values_hash)
          format.html { redirect_to '/query', :notice => "#{rel_name} : #{values_hash.inspect}"}
          format.json { head :no_content }
        else
          format.html {redirect_to '/query', :notice => "insert did not happen properly"}
          format.json {head :no_content}
        end
        @relation_classes[rel_name].remove_connection
      end
    end
  end
    
  #Creates a new relation and adds it to the session database.
  def create
    schema = Hash.new
    rel_name = params[:relation_name]
    col_names = params[:column_names].split(";")
    col_types = params[:column_types].split(";")
    #FIXME Here we would want use jquery to dynamically join the corresponding types 
    #in a more elegant way. Alternatively, we can let the user specify his new relation
    #in Webdamlog and convert from there. Discuss with Emilien. He might do this implementation
    if col_names.size == col_types.size
      col_names.each_index do |i|
        schema[col_names[i]]=col_types[i]
      end
    end
    # WLBUDinsert 
    database(ENV['USERNAME']).create_relation(rel_name,schema)    
    respond_to do |format|
      format.html { redirect_to '/query', :notice => "#{@relation_classes.inspect}"}
      format.json { head :no_content }
    end
  end
end
