require 'set'
require 'json'
require 'pathname'
require 'fileutils'
require 'picture'
require 'contact'
#require 'wl_logger'
#require 'wl_tool'

# This helper manage database connection for a peer
#
# @@databases is the set of databse on which the peer is connected. In our app
# there is always exactly one.
#
# The class WLInstanceDatabase represent the object which provide methods to
# alter the database schema (add table)
#
# TODO all the methods open_connection and remove_connection defined for every
# model in this app are now totally useless. Think to remove them properly.
#
module WLDatabase  

  @@databases = Hash.new
  
  #Does nothing if the user already has his db setup. Otherwise, sets up his 
  #db. FIXME change the naming convention used for the db to something more 
  #standard.
  #
  def setupdb
    unless @@databases[ENV['USERNAME']]
      create_or_connect_db(ENV['USERNAME'])
    end
  end
  
  #Access a database loaded by the program using its database id. The id
  #for the database is usually the username of the user.
  #
  def database(database_id)
    @@databases[database_id]
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
    @@databases.delete(database_id)
  end
  
  #TODO Add namespace to WLSchema relation. The namespace is based on the database_id
  #TODO: Datetime and binary format have to be managed to be viewed properly.
  class WLInstanceDatabase
    include WLTool
    
    attr_accessor :id, :relation_classes, :configuration
    
    #Creates a new database with a name defined by the user's id. If the database
    #already exists, simply connects to it.
    def initialize(database_id)
      @id = database_id
      @db_name = "db/database_#{database_id}.db"
      @configuration = {:adapter => 'sqlite3', :database => @db_name}
      create_schema
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
    
    # This method creates a special table that represents the schema of the
    # database. Since database schemas are different for every user, storing
    # them is a quick way of loading efficient methods into the newly created
    # instance.
    # 
    def create_schema
      @relation_classes = Hash.new      
      #Create the WLSchema model.
      relation_name="WLSchema"
      database_instance = self
      @wlschema = create_class("#{relation_name}_#{@id}",ActiveRecord::Base) do
        @schema = {"name"=>"string","schema"=>"string"}
        @wl_database_instance = database_instance
        establish_connection @wl_database_instance.configuration
        attr_accessible :name, :schema
        validates_uniqueness_of :name
        self.table_name = relation_name        
        if !connection.table_exists?(table_name)
          connection.create_table table_name, :force => true do |t|
            t.string :name
            t.string :schema
          end
        else          
          WLLogger.logger.debug "try to create wlschema table in db #{@wl_database_instance.configuration} but it already exists"
        end
        def self.schema
          @schema
        end
        def self.open_connection
          establish_connection(@wl_database_instance.configuration)
        end
        def self.remove_connection
          super
        end
        WLLogger.logger.debug "create a model #{self} with its table #{table_name} with the schema #{@schema}"
      end      
      @relation_classes[relation_name]=@wlschema
       
      #Retrieve all the models. Requires to establish a connection.
      @wlschema.establish_connection @configuration
      @wlschema.all.each do |table|
        @relation_classes[table.name] = create_relation_class(table.name,JSON.parse(table.schema))
      end
      
      # XXX The error was basically impossible to guess but finally found it
      # do not add the User class here or Authlogic will not be able to handle
      # sessions properly.
      #
      
      @relation_classes['Pictures'] = Object.const_get("Picture").clone
      @relation_classes['Contacts'] = Object.const_get("Contact").clone
      #@wlschema.open_connection
      @wlschema.new(:name=>'Pictures',:schema=>Picture.schema.to_json).save
      @wlschema.new(:name=>'Contacts',:schema=>Contact.schema.to_json).save
      #@wlschema.remove_connection
      
      #FIXME: This is a dummy SQL query to insert test facts in Contacts
      Contact.new(:username=>'Emilien',:peerlocation=>'SIGMODpeer',:online=>true,:email=>"emilien.antoine@inria.fr",:facebook=>"Emilien Antoine").save
      Contact.new(:username=>'Julia',:peerlocation=>'SIGMODpeer', :online=>false,:email=>"stoyanovich@drexel.edu",:facebook=>"Julia Stoyanovich").save
      Contact.new(:username=>'Gerome',:peerlocation=>'SIGMODpeer',:online=>true,:email=>"miklau@cs.umass.edu",:facebook=>"Gerome Miklau").save
      Contact.new(:username=>'Serge',:peerlocation=>'SIGMODpeer',:online=>false,:email=>"serge.abiteboul@inria.fr",:facebook=>"Serge Abiteboul").save
      Contact.new(:username=>'Jules',:peerlocation=>'localhost',:online=>true,:email=>"jules.testard@mail.mcgill.ca",:facebook=>"Jules Testard").save
    end
    
    # The create relation method will create a new relation in the database as well.
    # as a new rails model class connected to that relation. It requires a schema
    # that will correspond to the table's relationnal schema.
    def create_relation(name,schema)
      name.capitalize!
      @relation_classes[name] = create_relation_class(name,schema)
      #@wlschema.open_connection
      begin
        if @wlschema.new(:name => name,:schema => schema.to_json).save
        else
          WLLogger.logger.warn "Relation wlschema was not properly updated"
        end
      rescue => error
        WLLogger.logger.fatal error
        raise error
      end
      #@wlschema.remove_connection
    end
    
    def create_relation_class(name,schema)
      database_instance = self
      create_class("#{name}_#{@id}",ActiveRecord::Base) do
        @schema = schema
        @wl_database_instance = database_instance
        establish_connection @wl_database_instance.configuration
        self.table_name=name
        connection.create_table table_name, :force => true do |t|
          schema.each_pair do |col_name,col_type|
            eval("t.#{col_type} :#{col_name}")
          end
          t.timestamps
        end if !connection.table_exists?(table_name)
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
          establish_connection @wl_database_instance.configuration
        end
        def self.remove_connection
          super
        end
      end
    end
  end
end