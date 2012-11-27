# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'set'
require 'json'
require 'pathname'

#TODO Change database_id into database_id
module Database
  @@databases = Hash.new
  
  #TODO add option to create
  def database(database_id)
    @@databases[database_id]
  end
  
  class WLInstanceDatabase
    attr_accessor :db_name, :relations, :schemas, :wlschema, :configuration
    
    #Creates a new database with a name defined by the user's id. If the database
    #already exists, simply connects to it.
    def initialize(database_id)
      @database_id = database_id
      @db_name = "db/database_#{@database_id}.db"  
      create_or_retrieve_database
    end
    
    #Resets instance schemas and relations attributes.
    #Remove all generated model classes.
    def destroy_classes
      #Remove all generated model classes
      @relations.values.each do |class_object|
        delete_class(class_object)
      end
      delete_class(@wlschema)
      @relations = Hash.new
      @schema = Hash.new
    end
    
    #Removes the database file and generated model classes. Also 
    #resets instance schemas and relations attributes. 
    #Use create_or_retrieve_database to reinitialize.
    def destroy
      #Remove all generated model classes
      destroy_classes
      
      #Destroy the db
      path = Pathname.new(@db_name)
      rails_root = File.expand_path('.')
      file = path.absolute? ? path.to_s : File.join(rails_root, path)
      FileUtils.rm(file)
    end
    
    def create_or_retrieve_database
      @configuration = {:adapter => 'sqlite3', :database => @db_name}
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
        @configuration = database.configuration
        establish_connection @configuration
        self.table_name = relation_name
        connection.create_table table_name, :force => true do |t|
          t.string :name
          t.string :schema
        end if !connection.table_exists?(table_name)
      end
      
      @schemas[relation_name]={"name"=>"string","schema"=>"string"}
      @relations[relation_name]=@wlschema
      @wlschema.establish_connection @configuration
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
      create_class("#{name}",ActiveRecord::Base) do
        @configuration = database.configuration
        establish_connection @configuration
        self.table_name=name
        connection.create_table table_name, :force => true do |t|
          schema.each_pair do |col_name,col_type|
            eval("t.#{col_type} :#{col_name}")
          end
        end if !connection.table_exists?(table_name)
        def self.insert(values)
          establish_connection @configuration
          self.new(values).save
        end
        def self.find(id)
          establish_connection @configuration
          super id
        end
        def self.all
          establish_connection @configuration
          super
        end
        def self.inspect
          establish_connection @configuration
          super
        end
      end      
    end
    
    def create_class(class_name, superclass, &block)
      klass = Class.new superclass, &block
      Object.const_set class_name, klass
    end
    
    def delete_class(klass)
      Object.class_eval do
        remove_const(klass.name.intern) if const_defined?(klass.name.intern)
      end
    end
  
  end
  
  #Creates a new database for the user using his database_id as key. If database
  #already exists, simply connects to it (no override).
  def create_or_connect_db(database_id)
    @@databases[database_id]=WLInstanceDatabase.new(database_id)
    @@databases[database_id]
  end
  
  #FIXME Do we want to destroy the object explicitly? classes?
  def close_connection(database_id)
    @@databases[database_id].destroy_classes
    @@databases.delete(database_id)
  end
  
  def destroy(database_id)
    @@databases[database_id].destroy
    @@databases[database_id].delete(database_id)
  end
end