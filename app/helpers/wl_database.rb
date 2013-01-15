# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'set'
require 'json'
require 'pathname'
require 'fileutils'
require 'yaml'
require 'active_record'
require 'app/models/account'
require 'app/helpers/wl_launcher'


module Database
  @@databases = Hash.new
  
  

  
  def database(database_id)
    @@databases[database_id]
  end
  
  #TODO Add namespace to WLSchema relation. The namespace is based on the database_id
  class WLInstanceDatabase
    attr_accessor :id, :relation_classes, :@configuration
    
    #Creates a new database with a name defined by the user's id. If the database
    #already exists, simply connects to it.
    def initialize(configuration)
      retrieve_database(configuration)
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
      case @configuration['adapter']
      when 'sqlite3'
        path = Pathname.new(@db_name)
        rails_root = File.expand_path('.')
        file = path.absolute? ? path.to_s : File.join(rails_root, path)
        FileUtils.rm(file)
      when 'mysql2'
        ActiveRecord::Base.connection.drop_database @db_name       
      end
    end
    
    def retrieve_database(configuration)
      @id = ENV['DBID']
      @db_name = configuration['database']
      create_database
      create_schema if @id!='MANAGER'
    end
    
    #This method creates the database and establishes the connection.
    #I wanted to remove the need for migrations, meaning every models creates its table (if it does not already exist)
    #on startup.
    def create_database
      case @configuration['adapter']
      when 'mysql2'
        ActiveRecord::Base.establish_connection(@configuration.merge('database' => nil))
        ActiveRecord::Base.connection.execute("CREATE DATABASE IF NOT EXISTS #{@configuration['database']};")
        ActiveRecord::Base.establish_connection(@configuration)
      end
    end      
    
    #This method creates a special table that represents the schema of the database.
    #Since database schemas are different for every user, storing them is a quick
    #way of loading efficient methods into the newly created instance.
    def create_schema
      @relation_classes = Hash.new
      #Create the WLSchema model.
      relation_name="WLSchema"
      @wlschema = create_class("#{relation_name}_#{@id}",ActiveRecord::Base) do
        @schema = {"name"=>"string","schema"=>"string"}
        self.table_name = relation_name
        connection.create_table table_name, :force => true do |t|
          t.string :name
          t.string :schema
        end if !connection.table_exists?(table_name)
        def self.schema
          @schema
        end
      end
      
      @relation_classes[relation_name]=@wlschema
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
      rescue
        raise "Class was not created!"
      end
      
      if @wlschema.new(:name => name,:schema => schema.to_json).save
        #good
      else
        puts "Relation was not properly updated"
      end
    end
    
    #Creates the relation class extends ActiveRecord::Base and follows the model
    #given by schema.
    #TODO Add image field option
    def create_relation_class(name,schema)
      create_class("#{name}_#{@id}",ActiveRecord::Base) do
        @schema = schema
        self.table_name=name
        begin
          connection.create_table table_name, :force => true do |t|
            schema.each_pair do |col_name,col_type|
              eval("t.#{col_type} :#{col_name}")
              #XXX this feature has not been tested yet!
              if (col_type.upper.include?('IMAGE'))
                case connection.class
                when ActiveRecord::ConnectionAdapters::SQLite3Adapter
                  fields = "t.binary :#{col_name}_file\n"
                  fields += "t.binary :#{col_name}_small_file\n"
                  fields += "t.binary :#{col_name}_thumb_file\n"
                  eval(fields)
                when ActiveRecord::ConnectionAdapters::Mysql2Adapter
                  fields = "execute \"ALTER TABLE users ADD COLUMN #{col_name}_file LONGBLOB\""
                  fields += "execute \"ALTER TABLE users ADD COLUMN #{col_name}_small_file LONGBLOB\""
                  fields += "execute \"ALTER TABLE users ADD COLUMN #{col_name}_thumb_file LONGBLOB\"\n"
                  eval(fields)
                end
              end
            end
          end if !connection.table_exists?(table_name)          
        rescue
          raise "Schema has been mistyped!"
        end
        
        #XXX this feature has not been tested yet!
        #XXX this might not work for several images in the same table. Need more testing.
        schema.values.each_pair do |col_name, col_type|
          if (col_type.upper.include?('IMAGE'))
            attr_accessible col_name.to_sym
            has_attached_file col_name.to_sym,
              :storage => :database, 
              :styles => {
              :thumb => "150x150>",
              :small => "300x300>"
            },
              :url => '/:class/:id/:attachment?style=:style'
            default_scope select_without_file_columns_for(col_name.to_sym)
          end
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
      end      
    end
    
    #Utility method for creating a class
    def create_class(class_name, superclass, &block)
      klass = Class.new superclass, &block
      Object.const_set class_name, klass
    end
    
    #Utility method for deleting a class
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
  
  #This method destroys a single database and its corresponding peer server.
  def destroy(database_id)
    account=Account.find(:username => database_id)
    #Drop each account specific database.
    ActiveRecord::Base.connection.execute("DROP DATABASE IF EXISTS #{['RAILS_ENV']}_#{account.username};");
    #Close each account server
    WLLauncher.exit_server(account.port)
    @@databases[database_id].delete(database_id)
  end
  
  #This method destroys all its peer databases and kills all corresponding peer servers.
  def destroy_all
    accounts=Account.all
    accounts.each_with_index do |account,i|
      puts "#{i} : #{account.inspect}"
      #Drop each account specific database.
      ActiveRecord::Base.connection.execute("DROP DATABASE IF EXISTS #{['RAILS_ENV']}_#{account.username};");
      #Close each account server
      WLLauncher.exit_server(account.port)
    end
    @@databases.clear
  end
end