# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'set'
require 'json'
require 'pathname'
require 'fileutils'

module Database
  @@databases = Hash.new
  
  def database(database_id)
    @@databases[database_id]
  end
  
  #TODO Add namespace to WLSchema relation. The namespace is based on the database_id
  class WLInstanceDatabase
    attr_accessor :id, :relation_classes, :configuration
    
    #Creates a new database with a name defined by the user's id. If the database
    #already exists, simply connects to it.
    def initialize(database_id)
      create_or_retrieve_database(database_id)
    end
    
    #Resets instance schemas and relation_classes attributes.
    #Remove all generated model classes.
    def destroy_classes
      #Remove all generated model classes
      @relation_classes.values.each do |class_object|
        delete_class(class_object)
      end
      delete_class(@wlschema)
      @relation_classes = Hash.new
    end
    
    #Removes the database file and generated model classes. Also 
    #resets instance schemas and relation_classes attributes. 
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
    
    def create_or_retrieve_database(database_id)
      @id = database_id
      @db_name = "db/database_#{database_id}.db"      
      @configuration = {:adapter => 'sqlite3', :database => @db_name}
      create_schema
    end    
    
    #This method creates a special table that represents the schema of the database.
    #Since database schemas are different for every user, storing them is a quick
    #way of loading efficient methods into the newly created instance.
    def create_schema
      @relation_classes = Hash.new
      database=self
      
      
      #Create the WLSchema model.
      relation_name="WLSchema"
      @wlschema = create_class("#{relation_name}_#{@id}",ActiveRecord::Base) do
        @schema = {"name"=>"string","schema"=>"string"}
        @configuration = database.configuration
        establish_connection @configuration
        self.table_name = relation_name
        connection.create_table table_name, :force => true do |t|
          t.string :name
          t.string :schema
        end if !connection.table_exists?(table_name)
        def self.schema
          @schema
        end
        def self.open_connection
          establish_connection @configuration
        end
        def self.remove_connection
          super
        end
      end
      
      @relation_classes[relation_name]=@wlschema
      @wlschema.establish_connection @configuration 
      #Retrieve all the models
      @wlschema.all.each do |table|
        @relation_classes[table.name] = create_relation_class(table.name,JSON.parse(table.schema))
      end
    end
    
    #The create relation method will create a new relation in the database as well.
    #as a new rails model class connected to that relation. It requires a schema
    #that will correspond to the table's relationnal schema.
    #XXX The api need to be managed for mistyping
    def create_relation(name,schema)
      raise "Name should not be nil!" if name.nil?
      raise "Name should not be empty!" if name.empty?
      name.capitalize!
      begin 
        @relation_classes[name] = create_relation_class(name,schema)
      rescue error
        raise error
      end
      @wlschema.open_connection
      if @wlschema.new(:name => name,:schema => schema.to_json).save
        #good
      else
        puts "Relation was not properly updated"
      end
      @wlschema.remove_connection
    end
    
    #Creates the relation class extends ActiveRecord::Base and follows the model
    #given by schema.
    def create_relation_class(name,schema)
      database=self
      create_class("#{name}_#{@id}",ActiveRecord::Base) do
        @schema = schema
        @configuration = database.configuration
        establish_connection @configuration
        self.table_name=name
        begin
          connection.create_table table_name, :force => true do |t|
            schema.each_pair do |col_name,col_type|
              eval("t.#{col_type} :#{col_name}")
            end
          end if !connection.table_exists?(table_name)          
        rescue
          raise "Schema has been mistyped!"
        end
        def self.insert(values)
          self.new(values).save
        end
        def self.find(id)
          super id
        end
        def self.all
          super
        end
        def self.inspect
          super
        end
        def self.delete (id)
          tuple = self.find(id)
          tuple.destroy
        end
        def self.schema
          @schema
        end
        def self.open_connection
          establish_connection @configuration
        end
        def self.remove_connection
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