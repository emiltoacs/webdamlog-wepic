require 'lib/database'

class QueryController < ApplicationController
  include Database
  
  def index
    @relations = database(current_user.id).relations
    @schemas = database(current_user.id).schemas
  end
  
  def create
    puts params.inspect
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