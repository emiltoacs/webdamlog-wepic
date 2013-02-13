# due to some problem of rails loading all these test can be passed only one by
# one (see option -n when launching ruby test) do not include test_helper here
# unlike usual, it is included in the setup method since the modules have to be
# regenerated from scratch
require 'test/unit'
require 'wl_tool'
require 'wl_database'

#This class is meant to test and explain the database API to be used 
#by the rails controllers and WebdamLog.
#The suppress warning messages are used to avoid constant reassignment warnings.
#Constant reassignment should not be used in practice but is useful for purposes
#of testing.
#TODO : Avoid duplication of information in the Database module by reducing the 
#number of variables.
class WLDatabaseTest < Test::Unit::TestCase
  include WLDatabase
  include Kernel
  
  def setup
    @dbid = (0...8).map{('a'..'z').to_a[rand(26)]}.join
    ENV['USERNAME'] = @dbid

    # reload the models to allow builtins tables to be created
    require 'test_helper'
    require 'application'
    @id = @dbid
    @db_name = DBConf.config[:database]
    @configuration = {:adapter => DBConf.config[:adpater], :database => @db_name}
    @database = create_or_connect_db(@id,@db_name,@configuration)
  end
  
  def teardown
    @database.destroy
  end
  
  def test_10_setup_and_teardown
    assert(true)
  end
  

  def test_20_access_schema_from_class
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_model(relation_name,relation_schema)
    assert_equal(relation_schema,@database.relation_classes[relation_name].schema)
  end

  # Test the method tables_exists? succeed if the two buitins tables exists
  #
  def test_30_tables_exists?
    assert @database.table_exists_for_model?("Picture"), "Picture is a builtins table that should have been created"
    assert @database.table_exists_for_model?("Contact"), "Contact is a builtins table that should have been created"
    assert(@database.relation_classes["Picture"].ancestors.include? ActiveRecord::Base)
    assert(@database.relation_classes["Contact"].ancestors.include? ActiveRecord::Base)
  end

  # Check connection and two builtins tables wlschema and wlmeta
  #
  def test_31_connect_to_db
    # Check if database was created during the setup
    assert_equal(WLInstanceDatabase,@database.class)
    # Check if database contains the WLSchema relation
    wl_schema = WLInstanceDatabase::DATABASE_SCHEMA
    assert_equal({"name"=>"string","schema"=>"string"}, @database.relation_classes[wl_schema].schema)
    assert_equal(WLDatabase.to_table_name(wl_schema), @database.relation_classes[wl_schema].table_name)
    wl_meta = WLInstanceDatabase::DATABASE_META
    assert_equal(WLInstanceDatabase::DATABASE_META_SCHEMA, @database.relation_classes[wl_meta].schema)
    assert_equal(WLDatabase.to_table_name(wl_meta), @database.relation_classes[wl_meta].table_name)
    assert @database.relation_classes[wl_meta].first.init
  end
  
  def test_40_create_relation
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    assert_not_nil rel_klass = @database.create_model(relation_name,relation_schema), "fails to create the new relation #{relation_name}"
    assert rel_klass.ancestors.include? ActiveRecord::Base
    assert rel_klass.insert(:name=>"dog1", :race=>"race1", :age=>"7")
    #Assert relations has been added to database schemas and relation class attributes.
    assert_equal(WLDatabase.to_table_name("dog"),@database.relation_classes["Dog"].table_name)
    assert @database.table_exists_for_model? "Dog"
  end
  
  def test_50_deconnect
    close_connection(@dbid)
    assert_equal(nil,database(@dbid))
  end
  
  def test_60_reconnection
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_model(relation_name,relation_schema)
    close_connection(@dbid)
    @database = create_or_connect_db(@id,@db_name,@configuration)
    assert !@database.need_bootstrap?
    #Schema should contain the Dog table information
    wlschema = WLInstanceDatabase::DATABASE_SCHEMA
    tuples = @database.relation_classes[wlschema].all
    assert !tuples.empty?
    # TODO change test here    
    assert @database.table_exists_for_model?("Dog")
    assert_equal(WLDatabase.to_table_name("Dog"), @database.relation_classes[wlschema].where(:name=>WLDatabase.to_table_name("Dog")).first.name)
  end
  
  #You can check that the dog was added to the database with the following commands:
  #sqlite3 db/database_2.db
  #SELECT * FROM DOG;
  def test_70_insert_and_retrieve
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_model(relation_name,relation_schema)
    dog_table = @database.relation_classes["Dog"]
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    dog_table.insert(values)
    assert_equal(false,dog_table.all.empty?)
    bobby = dog_table.find(1)
    assert_equal("Bobby",bobby.name)
    assert_equal(2,bobby.age)
    assert_equal("labrador",bobby.race)
  end
  
  def test_80_delete
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_model(relation_name,relation_schema)
    dog_table = @database.relation_classes["Dog"]
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    dog_table.insert(values)
    assert_equal(false,dog_table.all.empty?)
    dog_table.delete(1)
    assert_equal(true,dog_table.all.empty?)
  end
  
end