require 'test_helper'
require 'test/unit'

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
    require 'environment'
    @dbid = (0...6).map{('a'..'z').to_a[rand(26)]}.join
    @database = create_or_connect_db(@dbid)
  end
  
  def teardown
    @database.destroy
  end
  
  def test_1_setup_and_teardown
    assert(true)
  end
  
  def test_2_access_schema_from_class
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    assert_equal(relation_schema,@database.relation_classes[relation_name].schema)
  end
  
  def test_3_connect_to_db
    #Check if database was created during the setup
    assert_equal(WLInstanceDatabase,@database.class)
    #Check if database contains the WLSchema relation
    assert_equal({"name"=>"string","schema"=>"string"},@database.relation_classes["WLSchema"].schema)
    assert_equal("WLSchema",@database.relation_classes["WLSchema"].table_name)
  end
  
  def test_4_create_relation
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    debugger
    assert_not_nil rel_klass = @database.create_relation(relation_name,relation_schema), "fails to create the new relation #{relation_name}"
    assert rel_klass.insert(:name=>"dog1", :race=>"race1", :age=>"7")
    #Assert relations has been added to database schemas and relation class attributes.
    assert_equal("Dog",@database.relation_classes["Dog"].table_name)
    assert @database.table_exists? "Dog"
  end
  
  def test_5_deconnect
    close_connection(@dbid)
    assert_equal(nil,database(@dbid))
  end
  
  def test_6_reconnection
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    close_connection(@dbid)    
    @database = create_or_connect_db(@dbid)
    #Schema should contain the Dog table information
    tuples = @database.relation_classes["WLSchema"].all
    assert !tuples.empty?
    # TODO change test here 
    #assert_equal("Dog", @database.relation_classes["WLSchema"].find(1).name)
  end
  
  #You can check that the dog was added to the database with the following commands:
  #sqlite3 db/database_2.db
  #SELECT * FROM DOG;
  def test_7_insert_and_retrieve
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    dog_table = @database.relation_classes["Dog"]
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    dog_table.insert(values)
    assert_equal(false,dog_table.all.empty?)
    bobby = dog_table.find(1)
    assert_equal("Bobby",bobby.name)
    assert_equal(2,bobby.age)
    assert_equal("labrador",bobby.race)
  end
  
  def test_8_delete
    relation_name = "Dog"
    relation_schema = {"name" => "string", "race" => "string", "age" => "integer"}
    @database.create_relation(relation_name,relation_schema)
    dog_table = @database.relation_classes["Dog"]
    values = {"name" => "Bobby", "age" => 2, "race"=> "labrador"}
    dog_table.insert(values)
    assert_equal(false,dog_table.all.empty?)
    dog_table.delete(1)
    assert_equal(true,dog_table.all.empty?)
  end

  # Test the method tables_exists? succeed if the two buitins tables exists
  #
  def test_9_tables_exists?
    @database.table_exists? "Pictures"
    @database.table_exists? "Contact"
  end
end