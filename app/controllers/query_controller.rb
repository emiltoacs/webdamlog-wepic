require 'lib/database'

class QueryController < ApplicationController
  include Database
  
  def index
    @relations = database(current_user.id).relations
    @schemas = database(current_user.id).schemas
    #flash[:notice]="#{@relations.inspect} : #{@schemas.inspect}"
  end
  
  #Insert a tuple in the instance database
  def insert
    @relations = database(current_user.id).relations
    @schemas = database(current_user.id).schemas
    rel_name = params[:relation][:name]
    values = params[:values].split(";")
    values_hash = Hash.new
    @schemas[rel_name].keys.each_index do |i|
      values_hash[@schemas[rel_name].keys[i]]=values[i] 
    end
    respond_to do |format|
      if @relations[rel_name].insert(values_hash)
        format.html { redirect_to '/query', :notice => "#{rel_name} : #{values_hash.inspect}"}
        format.json { head :no_content }
      else
        format.html {redirect_to '/query', :notice => "insert did not happen properly"}
        format.json {head :no_content}
      end
    end
  end
    
  #Creates a new relation and adds it to the session database.
  def create
    schema = Hash.new
    rel_name = params[:relation_name]
    col_names = params[:column_names].split(";")
    col_types = params[:column_types].split(";")
    if col_names.size == col_types.size
      col_names.each_index do |i|
        schema[col_names[i]]=col_types[i]
      end
    end
    database(current_user.id).create_relation(rel_name,schema)    
    respond_to do |format|
      format.html { redirect_to '/query', :notice => "#{rel_name} : #{schema.inspect}\n#{@relations.inspect}\n#{@schemas.inspect}"}
      format.json { head :no_content }
    end    
  end
end

class CreateRelationController < QueryController
  def create
    @create_relation = CreateRelation.new(params[:create_relation])
    schema = Hash.new
    col_names = @create_relation.col_names.split(";")
    col_types = @create_relation.col_names.split(";")
    if col_names.size == col_types.size
      col_names.each_index do |i|
        schema[col_names[i]]=col_types[i]
      end
    end
    create_relation(@creat_relation.rel_name,schema)
    respond_to do |format|
      format.html { redirect_to :query }
      format.json { head :no_content }
    end     
  end
  
  def destroy
    @create_relation = CreateRelation.find(params[:id])
    @create_relation.destroy
    respond_to do |format|
      format.html { redirect_to :query }
      format.json { head :no_content }
    end     
  end
end