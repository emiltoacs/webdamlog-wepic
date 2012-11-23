# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'set'

module Database
  @@databases = Hash.new
  
  def database(user_id)
    @@databases[user_id]
  end
  
  class WLInstanceDatabase
    attr_accessor :db_name, :relations, :schemas
    #Creates a new database with a name defined by the user's id. If the database
    #already exists, simply connects to it.
    def initialize(user_id)
      @db_name = "db/database_#{user_id}.db"
      @relations = Hash.new #need to retrieve relations from db upon reset
      @schemas = Hash.new #need tp retrieve schema from db upon reset
    end
    
    #The create relation method will create a new relation in the database as well.
    #as a new rails model class connected to that relation. It requires a schema
    #that will correspond to the table's relationnal schema.
    def create_relation(relation_name,schema)
      database=self
      relation_name.capitalize!
      relation_class = create_class(relation_name,ActiveRecord::Base) do
        puts "dbname : #{database.db_name}"
        establish_connection :adapter => 'sqlite3', :database => database.db_name
        self.table_name=relation_name
        connection.create_table table_name, :force => true do |t|
            schema.each_pair do |col_name,col_type|
              eval("t.#{col_type} :#{col_name}")
            end
          end if !connection.table_exists?(table_name)    
      end
      @relations[relation_name]=relation_class
      @schemas[relation_name]=schema
      relation_class
    end
    
  def create_class(class_name, superclass, &block)
    klass = Class.new superclass, &block
    Object.const_set class_name, klass
  end
  
  end
  
  class WLInstanceTable < ActiveRecord::Base
  end 
  
  #Creates a new database for the user using his user_id as key. If database
  #already exists, simply connects to it (no override).
  def create_or_connect_db(user_id)
    @@databases[user_id]=WLInstanceDatabase.new(user_id)
    @@databases[user_id]
  end
end