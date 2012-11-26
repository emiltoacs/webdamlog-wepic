# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'set'
require 'json'

#TODO Change database_id into database_id
module Database
  @@databases = Hash.new
  
  #TODO add option to create
  def database(database_id)
    @@databases[database_id]
  end
  
  class WLInstanceDatabase < ActiveRecord::Base
    attr_accessor :db_name, :relations, :schemas, :wlschema
    
    #Creates a new database with a name defined by the user's id. If the database
    #already exists, simply connects to it.
    def initialize(database_id)
      @database_id = database_id
      @db_name = "db/database_#{@database_id}.db"      
      create_schema
    end
    
    #This method creates a special table that represents the schema of the database.
    #Since database schemas are different for every user, storing them is a quick
    #way of loading efficient methods into the newly created instance.
    def create_schema
      @relations = Hash.new
      @schemas = Hash.new
      database=self
      relation_name="WLSchema"
      @wlschema = create_class(relation_name,ActiveRecord::Base) do
        @db_name = database.db_name
        establish_connection :adapter => 'sqlite3', :database => @db_name
        self.table_name = relation_name
        connection.create_table table_name, :force => true do |t|
          t.string :name
          t.string :schema
        end if !connection.table_exists?(table_name)
      end
      
      @schemas[relation_name]={"name"=>"string","schema"=>"string"}
      @relations[relation_name]=@wlschema
      @wlschema.establish_connection :adapter => 'sqlite3', :database => @db_name
      #Retrieve all the models
      @wlschema.all.each do |table|
        @schemas[table.name]= JSON.parse(table.schema)
        @relations[table.name] = create_relation_class(table.name,table.schema)
      end
    end
    
    #The create relation method will create a new relation in the database as well.
    #as a new rails model class connected to that relation. It requires a schema
    #that will correspond to the table's relationnal schema.
    def create_relation(name,schema)
      name.capitalize!
      @schemas[name]=schema
      @relations[name] = create_relation_class(name,schema)
      if @wlschema.new(:name => name,:schema => schema.to_json).save
        #good
      else
        puts "Relation was not properly updated"
      end
    end
    
    def create_relation_class(name,schema)
      database=self
      #_#{@database_id}"
      create_class("#{name}",ActiveRecord::Base) do
        @db_name = database.db_name
        establish_connection :adapter => 'sqlite3', :database => @db_name
        self.table_name=name
        connection.create_table table_name, :force => true do |t|
          schema.each_pair do |col_name,col_type|
            eval("t.#{col_type} :#{col_name}")
          end
        end if !connection.table_exists?(table_name)
        def self.insert(values)
          establish_connection :adapter => 'sqlite3', :database => @db_name
          self.new(values).save
        end
        def self.find(id)
          establish_connection :adapter => 'sqlite3', :database => @db_name
          super id
        end
        def self.all
          establish_connection :adapter => 'sqlite3', :database => @db_name
          super
        end
        def self.inspect
          establish_connection :adapter => 'sqlite3', :database => @db_name
          super
        end
      end      
    end
    
    def create_class(class_name, superclass, &block)
      klass = Class.new superclass, &block
      Object.const_set class_name, klass
    end
  
  end
  
  #Creates a new database for the user using his database_id as key. If database
  #already exists, simply connects to it (no override).
  def create_or_connect_db(database_id)
    @@databases[database_id]=WLInstanceDatabase.new(database_id)
    @@databases[database_id]
  end
  
  #FIXME Do we want to destroy the object explicitly?
  def close_connection(database_id)
    @@databases.delete(database_id)
  end
end