require 'set'
require 'json'
require 'pathname'
require 'fileutils'
require 'active_support/core_ext/string'
require './lib/wl_tool'

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
  
  # Does nothing if the user already has his db setup. Otherwise, sets up his
  # db.
  #
  def setup_database_server
    unless @@databases[Conf.env['username']]
      # Connect to postgres database with admin user postgres that always
      # exist. Then create the first database for the manager
      if Conf.db[:adapter] == 'postgresql'
        ActiveRecord::Base.establish_connection adapter:'postgresql', username:'postgres', password:'', database:'postgres'
        ActiveRecord::Base.connection.create_database Conf.db['database']
      end
      create_or_connect_db(Conf.env['username'], Conf.db['database'], Conf.db)
    end
  end
  
  # Access a database loaded by the program using its database id. The id for
  # the database is usually the username of the user.
  #
  def database(database_id)
    @@databases[database_id]
  end

  # Creates a new database for the user using his database_id as key. If
  # database already exists, simply connects to it (no override).
  def create_or_connect_db(database_id,db_name,configuration)
    @@databases[database_id]=WLInstanceDatabase.new(database_id,db_name,configuration)
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

  def self.to_model_name table_name
    table_name.classify
  end

  def self.to_table_name model_name
    model_name.tableize
  end
  
  #TODO Add namespace to WLSchema relation. The namespace is based on the database_id
  #TODO: Datetime and binary format have to be managed to be viewed properly.
  class WLInstanceDatabase
    include WLTool
    
    attr_accessor :id, :relation_classes, :configuration

    DATABASE_SCHEMA = WLDatabase.to_model_name("WLSchema")
    DATABASE_META = WLDatabase.to_model_name("DatabaseMeta")
    DATABASE_META_SCHEMA = {"id" => "string", "dbname" => "string", "configuration" => "string", "init" => "boolean"}

    # Creates a new database with a name defined by the user's id. If the
    # database already exists, simply connects to it.
    #
    def initialize(database_id,db_name,configuration)
      @id = database_id
      @db_name = db_name
      @configuration = configuration
      @initialized ||= false
      create_schema
      if need_bootstrap?
        init_bootstrap
      end
      @initialized = true
    end

    def need_bootstrap?
      meta = DATABASE_META
      if table_exists_for_model? meta and relation_classes[meta].where(:init=>true).first.init
        false
      else
        true
      end
    end

    # Test and check if database is initialized properly
    #
    # Force @initialized to nil to check if an old database may fit our model
    #
    def initialized?
      if @initialized.nil?
        unless db_exists? @db_name
          if @relation_classes.empty?
            @initialized = false
          else
            @relation_classes.each do |model|
              unless table_exists_for_model? model
                WLLogger.logger.warn "database #{@db_name} seems to be corrupted: #{model} has no table in the database"
                @initialized=false
              end
              @initilized = true
            end
            WLLogger.logger.warn "database #{@db_name} exists but there is no model to load"
            @initialized = false
          end
        else
          @initialized = false
        end
      else
        if @initialized
          if @wlschema.nil? or !table_exists_for_model?(@wlschema)
            WLLogger.logger.warn "database #{@db_name} seems to be corrupted: wlschema not found"
            @initialized=false
          end
        end
        return @initialized
      end
    end

    #Resets instance schemas and relation_classes attributes.
    #Remove all generated model classes.
    def destroy_classes
      #Remove all generated model classes
      @relation_classes.values.each do |class_object|
        delete_class(class_object)
      end
      delete_class(@wlschema)
      @initialized = false
      @relation_classes = Hash.new
    end
    
    # Removes the database file and generated model classes. Also resets
    # instance schemas and relation_classes attributes. Use
    # create_or_retrieve_database to reinitialize.
    def destroy
      #Remove all generated model classes
      destroy_classes      
      #Destroy the db
      path = Pathname.new(@db_name)
      rails_root = File.expand_path('.')
      file = path.absolute? ? path.to_s : File.join(rails_root, path)
      FileUtils.rm(file)
    end

    def db_exists? (db_name)
      return File.exists?(db_name)
    end
    
    # This method creates a special table that represents the schema of the
    # database. Since database schemas are different for every user, storing
    # them is a quick way of loading efficient methods into the newly created
    # instance.
    # 
    def create_schema
      # The hash that keep the correspondance between the model class name and
      # the class themsleves
      #
      @relation_classes ||= Hash.new
      unless @relation_classes.empty?
        WLLogger.logger.warn "try to recreate a object from the database but #{@relation_classes.length} models are left in memory #{@relation_classes}"
      end

      # The model of the schema itself stored in the database
      #
      # TODO write create_model_class with a block to introduced validators
      # (validates_uniqueness_of :name) as in comments below
      #
      @wlschema = create_model_class(DATABASE_SCHEMA, {"name"=>"string","schema"=>"string"})
      #      @wlschema = create_class("#{relation_name}_#{@id}",ActiveRecord::Base) do
      #        @schema = {"name"=>"string","schema"=>"string"}
      #        @wl_database_instance = database_instance
      #        establish_connection @wl_database_instance.configuration
      #        attr_accessible :name, :schema
      #        validates_uniqueness_of :name
      #        self.table_name = relation_name
      #        if !connection.table_exists?(table_name)
      #          connection.create_table table_name, :force => true do |t|
      #            t.string :name
      #            t.string :schema
      #          end
      #        else
      #          WLLogger.logger.debug "try to create wlschema table in db #{@wl_database_instance.configuration} but it already exists"
      #        end
      #        def self.schema
      #          @schema
      #        end
      #        WLLogger.logger.debug "create a model #{self} with its table #{table_name} schema #{@schema} in database #{@wl_database_instance}"
      #      end
      @relation_classes[DATABASE_SCHEMA]=@wlschema
      #Retrieve all the models. Requires to establish a connection.
      @wlschema.establish_connection @configuration
      @wlschema.all.each do |table|
        klass = create_model_class(table.name,JSON.parse(table.schema))
        @relation_classes[klass.name] = klass
        @wlmeta = @relation_classes[klass.name] if klass.name == DATABASE_META
      end
    end

    def init_bootstrap
      # Create the meta data for the current database, usefull on reload   
      @wlmeta = create_model(DATABASE_META,DATABASE_META_SCHEMA)
      @wlmeta.new(:id=>@id, :dbname=>@db_name, :configuration=>@configuration, :init=>true).save
      # XXX The error was basically impossible to guess but finally found it
      # do not add the User class here or Authlogic will not be able to handle
      # sessions properly.
      # 
      # Init manually the two buildins relations created when rails has parsed
      # the models
      pic = WLTool::class_exists("Picture", ActiveRecord::Base)
      if pic.nil?
        load 'picture.rb'
        @relation_classes['Picture'] = Object.const_get("Picture")
      else
        @relation_classes['Picture'] = pic
      end
      con = WLTool::class_exists("Contact", ActiveRecord::Base)
      if con.nil?
        load 'contact.rb'
        @relation_classes['Contact'] = Object.const_get("Contact")
      else
        @relation_classes['Contact'] = con
      end

      # XXX some bootstrap relations
      @wlschema.new(:name=>Picture.table_name, :schema=>Picture.schema.to_json).save
      @wlschema.new(:name=>Contact.table_name, :schema=>Contact.schema.to_json).save
      @wlschema.new(:name=>Peer.table_name, :schema=>Peer.schema.to_json).save
      @wlschema.new(:name=>Program.table_name, :schema=>Program.schema.to_json).save

      # XXX some bootstrap facts
      Contact.new(:username=>'Emilien',:peerlocation=>'SIGMODpeer',:online=>true,:email=>"emilien.antoine@inria.fr",:facebook=>"Emilien Antoine").save
      Contact.new(:username=>'Julia',:peerlocation=>'SIGMODpeer', :online=>false,:email=>"stoyanovich@drexel.edu",:facebook=>"Julia Stoyanovich").save
      Contact.new(:username=>'Gerome',:peerlocation=>'SIGMODpeer',:online=>true,:email=>"miklau@cs.umass.edu",:facebook=>"Gerome Miklau").save
      Contact.new(:username=>'Serge',:peerlocation=>'SIGMODpeer',:online=>false,:email=>"serge.abiteboul@inria.fr",:facebook=>"Serge Abiteboul").save
      Contact.new(:username=>'Jules',:peerlocation=>'localhost',:online=>true,:email=>"jules.testard@mail.mcgill.ca",:facebook=>"Jules Testard").save
    end
    
    # The create relation method will create a new relation in the database as well.
    # as a new rails model class connected to that relation. It requires a schema
    # that will correspond to the table's relationnal schema.
    #
    def create_model(name,schema)
      model_klass = create_model_class(name,schema)
      @relation_classes[name] = model_klass
      begin
        if @wlschema.new(:name => model_klass.table_name,:schema => model_klass.schema.to_json).save
        else
          WLLogger.logger.warn "Relation wlschema was not properly updated, record should be invalid according to the model"
        end
      rescue => error
        WLLogger.logger.warn "In create_model with #{name} #{schema} #{error}"
        raise error
      end
      return @relation_classes[name]
    end

    # Create the relation as a model and a table in the database. Return the
    # class of the model created if succeed. it should be called by
    # create_relation
    #
    def create_model_class(name,schema)
      database_instance = self
      config = Conf.db
      model_name = WLDatabase.to_model_name("#{name}")
      klass = create_class(model_name,AbstractDatabase) do
        @schema = schema
        @wl_database_instance = database_instance
        if table_name.nil? or table_name.empty?
          self.table_name = WLDatabase.to_table_name model_name
        end
        #establish_connection config
        if !connection.table_exists?(table_name)
          connection.create_table table_name, :force => true do |t|
            schema.each_pair do |col_name,col_type|
              eval("t.#{col_type} :#{col_name}")
            end
            t.timestamps
          end
        else
          WLLogger.logger.debug "try to create #{table_name} table in db #{config} for model #{model_name} but it already exists"
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
        WLLogger.logger.debug "create a model #{model_name} with its table #{table_name} schema #{@schema} in database #{config}"
      end
      #klass.establish_connection config
      return klass
    end
      
    # Test if the given model or relation name in @relation_classes has a corresponding table in
    # the current database
    #
    def table_exists_for_model?(relation_name)
      if @relation_classes.key? relation_name
        model = @relation_classes[relation_name]
      else if relation_name.is_a? Class and relation_name.ancestors.includes? <= ActiveRecord::Base
          model = relation_name.table_name
        else
          WLLogger.logger.warn "no such table #{relation_name} in @wlschema"
          return false
        end
      end

      if model.respond_to? :connection and model.respond_to? :table_name
        return model.connection.table_exists?(model.table_name)
      else
        WLLogger.logger.warn "Value of #{relation_name} in @wlschema is #{@relation_classes[relation_name].class} expected to respond_to? :connection and :table_name"
        return false
      end
    end
  end

  module PostgresHelper

    def db_exists? db_name, db_username
      #conn = PGconn.new('localhost', 5432, '', '', db_name, db_username, "") # to use when password needed
      conn = PGconn.open(:dbname => db_name, :user => db_username)
      sql = "select count(1) from pg_catalog.pg_database where datname = '#{db_name}'"
      rs = conn.exec(sql)
      nb_database = rs.first['count']
      if nb_database == 0
        return false
      else
        return true
      end
    end

    
    
  end

end
